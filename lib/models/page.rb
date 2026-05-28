require './lib/json_api'
require './lib/services/keventer_api'
require './lib/models/recommended'
require './lib/services/cache_service'
require './lib/image_url_helper'

class Page
  attr_reader :name, :lang, :seo_title, :seo_description, :canonical,
              :recommended, :sections, :template, :show_in_footer

  # Sections treated as page chrome (rendered as the hero band, not in the body).
  HERO_SLUGS = %w[hero].freeze

  def initialize(data = {})
    @name = empty_to_nil(data['name'])
    @lang = data['lang']
    @seo_title = empty_to_nil(data['seo_title'])
    @seo_description = empty_to_nil(data['seo_description'])
    @canonical = empty_to_nil(data['canonical'])
    @cover = empty_to_nil(data['cover'])
    @template = data['template'] || 'overlay'
    @show_in_footer = data['show_in_footer'] == true
    @recommended = Recommended.create_list(data['recommended'] || [])
    @sections = (data['sections'] || []).each_with_object({}) do |section, hash|
      # Keep 'slug' in the value so body iteration knows each section's key.
      hash[section['slug']] = section.slice('slug', 'title', 'content', 'cta_text', 'cta_url', 'position')
    end
  end

  def flagship?
    @template == 'flagship'
  end

  def hero_section
    @sections.find { |slug, _| HERO_SLUGS.include?(slug) }&.last
  end

  # Sections that compose the page body (everything but hero), ordered by position.
  def body_sections
    @sections.values
             .reject { |s| HERO_SLUGS.include?(s['slug']) }
             .sort_by { |s| s['position'].to_i }
  end

  class << self
    attr_accessor :api_client
  end

  def self.create(json_api)
    json_api.ok? ? new(json_api.doc) : new
  end

  def self.load_from_json(file_path)
    create(NullJsonAPI.new(file_path))
  end

  def self.load_from_keventer(lang, slug)
    return create(@api_client) if @api_client
    
    url = KeventerAPI.page_url(lang, slug)
    cache_key = "page_#{lang}_#{slug}_#{url}"
    
    json_api = CacheService.get_or_set(cache_key) do
      JsonAPI.new(url)
    end
    
    create(json_api)
  end

  def cover
    ImageUrlHelper.replace_s3_with_cdn(@cover)
  end

  private

  def empty_to_nil(value)
    value.nil? || value.empty? ? nil : value
  end
end
