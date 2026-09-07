require 'faraday'
require 'nokogiri'
require 'set'
require './lib/site_crawl/fetcher'
require './lib/site_crawl/report'

# Walks the site and reports the internal references that do not land on the
# page they name. A link, a canonical or an alternate pointing at a redirect
# spends a hop it did not need to; one pointing at an error names a page that
# was never published. Neither is visible from inside a template, which is why
# they kept turning up one section at a time.
class SiteCrawl
  # Files that are not pages: following them tells us nothing and downloading
  # them is the slow part. sitemap.xml is deliberately not here — it is a list
  # of URLs we do want to check.
  ASSET_EXTENSIONS = %w[.css .js .png .jpg .jpeg .gif .svg .webp .ico .pdf .woff .woff2 .ttf .eot .mp3 .mp4].freeze
  SKIPPED_SCHEMES = %w[# mailto: tel: javascript: data:].freeze

  Reference = Struct.new(:source, :target, :kind)
  Finding = Struct.new(:target, :status, :location, :references)

  attr_reader :visited

  def initialize(base_url, max_pages: 400, pause: 0.05, logger: nil)
    @base = URI.parse(base_url)
    @max_pages = max_pages
    @pause = pause
    @logger = logger
    @visited = Set.new
    @fetcher = Fetcher.new
    @references = Hash.new { |h, k| h[k] = [] }
  end

  def run
    queue = [normalize(@base.to_s), normalize(URI.join(@base, '/sitemap.xml').to_s)].compact
    until queue.empty? || @visited.size >= @max_pages
      url = queue.shift
      next if @visited.include?(url)

      @visited << url
      queue.concat(visit(url))
      sleep @pause if @pause.positive?
    end
    self
  end

  # The references of one page, and the ones worth walking into next.
  def visit(url)
    body, content_type = fetch_page(url)
    return [] if body.nil?

    references_in(url, body, content_type).each { |ref| @references[ref.target] << ref }
                                          .map(&:target)
                                          .reject { |target| @visited.include?(target) }
  end

  # A reference worth reporting is one whose target does not answer 200.
  def findings
    @findings ||= @references.keys.sort.filter_map do |target|
      status, location = @fetcher.status(target)
      Finding.new(target, status, location, @references[target]) unless status == 200
    end
  end

  def report
    Report.new(findings, @visited.size).to_s
  end

  def references_in(source, body, content_type)
    if content_type.to_s.include?('xml')
      sitemap_references(source, body)
    else
      html_references(source, body)
    end
  end

  def sitemap_references(source, body)
    body.scan(%r{<loc>([^<]+)</loc>}).flatten.filter_map { |loc| build_reference(source, loc, :sitemap) }
  end

  def html_references(source, body)
    doc = Nokogiri::HTML(body)
    {
      'a[href]' => :link,
      'link[rel="canonical"]' => :canonical,
      'link[rel="alternate"][hreflang]' => :alternate
    }.flat_map do |selector, kind|
      doc.css(selector).filter_map { |node| build_reference(source, node['href'], kind) }
    end
  end

  def build_reference(source, href, kind)
    target = internal(href, source)
    Reference.new(source, target, kind) if target
  end

  # The absolute form of an internal href, or nil for anything we do not check:
  # another host, a mail or phone link, a bare fragment, a static file.
  def internal(href, source)
    return nil if href.nil? || href.strip.empty?
    return nil if SKIPPED_SCHEMES.any? { |scheme| href.start_with?(scheme) }

    uri = URI.join(source, href)
    checkable?(uri) ? normalize(uri.to_s) : nil
  rescue URI::Error
    nil
  end

  def checkable?(uri)
    %w[http https].include?(uri.scheme) &&
      uri.host == @base.host &&
      ASSET_EXTENSIONS.none? { |ext| uri.path.downcase.end_with?(ext) }
  end

  def normalize(url)
    uri = URI.parse(url)
    uri.fragment = nil
    uri.to_s
  rescue URI::Error
    nil
  end

  def fetch_page(url)
    body, content_type = @fetcher.page(url)
    @logger&.call(url) if body
    [body, content_type]
  end
end
