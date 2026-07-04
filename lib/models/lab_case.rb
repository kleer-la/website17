require 'yaml'
require 'date'
require './lib/helpers/custom_markdown'

# Kleer Lab case study, backed by a Markdown file with YAML front matter in
# data/lab/cases/*.md. Plain-Ruby port of the old Rails CaseRecord model:
# no ActiveRecord, no database. Front matter is parsed with stdlib YAML and
# the body is rendered with the app's existing redcarpet wrapper (CustomMarkdown),
# so the migration adds no new gem dependencies.
class LabCase
  FRONT_MATTER = /\A---\s*\n(.*?\n)^---\s*\n(.*)\z/m

  class << self
    attr_writer :cases_dir, :allow_drafts

    def cases_dir
      @cases_dir ||= File.expand_path('../../data/lab/cases', __dir__)
    end

    def allow_drafts?
      return @allow_drafts unless @allow_drafts.nil?

      ENV['RACK_ENV'] != 'production'
    end

    def all
      Dir.glob(File.join(cases_dir, '*.md')).filter_map { |path| from_path(path) }
    end

    def published
      all.select(&:published?).sort_by { |record| record.order || Float::INFINITY }
    end

    def featured
      published
    end

    def aggregate_metrics_for_home(limit: 4)
      metrics = []
      published.each do |record|
        break if metrics.size >= limit

        if record.hero_metric
          metrics << { 'value' => record.hero_metric['value'], 'label' => record.hero_metric['label'],
                       'source_case_slug' => record.slug }
        end
        record.secondary_metrics.each do |m|
          break if metrics.size >= limit

          metrics << { 'value' => m['value'], 'label' => m['label'], 'source_case_slug' => record.slug }
        end
      end
      metrics
    end

    def featured_testimonials(limit: 3)
      published.select { |r| r.feature_testimonial_on_home? && r.testimonial }.first(limit)
    end

    def find(slug)
      return nil unless slug.to_s.match?(/\A[a-z0-9_-]+\z/i)

      path = File.join(cases_dir, "#{slug}.md")
      return nil unless File.exist?(path)

      from_path(path)
    end

    def find_published(slug)
      record = find(slug)
      return nil unless record
      return record if record.published?
      return record if allow_drafts?

      nil
    end

    private

    def from_path(path)
      front_matter, content = parse(File.read(path))
      new(slug: File.basename(path, '.md'), front_matter: front_matter, content: content)
    rescue StandardError => e
      warn "[LabCase] failed to parse #{path}: #{e.class}: #{e.message}"
      nil
    end

    def parse(raw)
      if (match = raw.match(FRONT_MATTER))
        front = YAML.safe_load(match[1], permitted_classes: [Date], aliases: true) || {}
        [front, match[2]]
      else
        [{}, raw]
      end
    end
  end

  attr_reader :slug

  def initialize(slug:, front_matter:, content:)
    @slug = slug
    @data = front_matter || {}
    @content = content || ''
  end

  def published?
    @data['published'] == true
  end

  def feature_testimonial_on_home?
    @data['feature_testimonial_on_home'] == true
  end

  def order
    @data['order']
  end

  def title
    @data['title'] || client_label
  end

  def client_name
    @data['client_name']
  end

  def client_descriptor
    @data['client_descriptor']
  end

  def client_label
    client_name || client_descriptor
  end

  def industry
    @data['industry']
  end

  def duration
    @data['duration']
  end

  def hero_metric
    @data['hero_metric']
  end

  def hero_quote
    @data['hero_quote']
  end

  def secondary_metrics
    @data['secondary_metrics'] || []
  end

  def testimonial
    @data['testimonial']
  end

  def gallery
    @data['gallery'] || []
  end

  def date_published
    @data['date_published']
  end

  def date_modified
    @data['date_modified'] || date_published
  end

  def body_html
    @body_html ||= CustomMarkdown.new.render(@content)
  end
end
