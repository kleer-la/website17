require './lib/helpers/json_ld_helper'

# /llms.txt for kleer.la (#439): a curated index in Markdown for AI answer
# engines — who Kleer is, then its main pages by language, each with its
# canonical URL and one line. It reads what the sitemap reads and leaves out
# the same: hidden areas, unpublished services (the API lists neither), noindex
# courses and anything that redirects.
class LlmsTxt
  BASE = 'https://www.kleer.la'.freeze
  HEADINGS = {
    es: { services: 'Servicios', programs: 'Formación', courses: 'Cursos', resources: 'Recursos' },
    en: { services: 'Services', programs: 'Training', courses: 'Courses', resources: 'Resources' }
  }.freeze
  PATHS = {
    es: { services: 'servicios', programs: 'formacion', courses: 'cursos', resources: 'recursos' },
    en: { services: 'services', programs: 'training', courses: 'courses', resources: 'resources' }
  }.freeze

  def initialize(intro:, areas:, programs:, courses:, resources:)
    @intro = intro
    @areas = areas
    @programs = programs
    @courses = courses
    @resources = resources
  end

  def to_s
    "#{(["# Kleer\n\n> #{line(@intro, 500)}"] + %i[es en].flat_map { |lang| sections(lang) }).join("\n\n")}\n"
  end

  private

  def sections(lang)
    { services: area_entries(@areas, lang, :services), programs: area_entries(@programs, lang, :programs),
      courses: course_entries(lang), resources: resource_entries(lang) }
      .reject { |_, entries| entries.empty? }
      .map { |key, entries| "## #{HEADINGS[lang][key]}#{' (English)' if lang == :en}\n\n#{entries.join("\n")}" }
  end

  def area_entries(areas, lang, kind)
    areas.select { |a| a.lang.to_s == lang.to_s }.flat_map do |area|
      base = url(lang, kind, area.slug)
      [entry(area.name, base, area.summary)] +
        Array(area.services).map { |s| "  #{entry(s.name, service_url(lang, kind, area, s), heading(s.subtitle))}" }
    end
  end

  def service_url(lang, kind, area, service)
    kind == :programs ? url(lang, kind, service.slug) : "#{url(lang, kind, area.slug)}/#{service.slug}"
  end

  def course_entries(lang)
    seen = {}
    @courses.map(&:event_type).compact.filter_map do |et|
      next unless et.lang.to_s == lang.to_s && indexable_course?(et) && !seen[et.slug]

      seen[et.slug] = true
      entry(et.name, url(lang, :courses, et.slug), et.subtitle)
    end
  end

  def indexable_course?(event_type)
    !event_type.deleted && !event_type.noindex && event_type.external_site_url.to_s.strip.empty? &&
      !event_type.slug.to_s.empty?
  end

  def resource_entries(lang)
    @resources.select { |r| r.lang.to_s == lang.to_s && !r.title.to_s.strip.empty? }
              .map { |r| entry(r.title, url(lang, :resources, r.slug), r.description) }
  end

  def url(lang, kind, slug) = "#{BASE}/#{lang}/#{PATHS[lang][kind]}/#{slug}"

  def entry(name, url, description)
    text = line(description, 200)
    "- [#{line(name, 120)}](#{url})#{": #{text}" unless text.empty?}"
  end

  # A service subtitle is a heading and a paragraph; the heading says it, as
  # on the site's own service card.
  def heading(html) = html.to_s[%r{<h[1-6][^>]*>(.*?)</h[1-6]>}im, 1] || html

  # Plain text on one line: no HTML, no line breaks, at most `max` characters.
  def line(text, max)
    plain = text.to_s.gsub(/<[^>]+>/, ' ').gsub(/&nbsp;/, ' ').gsub(/\s+/, ' ').strip
    plain.length > max ? "#{plain[0, max - 1].rstrip}…" : plain
  end
end
