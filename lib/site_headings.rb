require 'faraday'
require 'uri'
require 'nokogiri'
require './lib/heading_outline'
require './lib/site_crawl/fetcher'

# Checks the heading outline (HeadingOutline) of every page in the sitemap of a
# deployed site. The request specs check the templates with fixtures; this
# checks what is published, since Keventer content changes without a deploy.
#
# The sitemap names production URLs on every site, so each one is read on the
# host being checked.
class SiteHeadings
  MAX_REDIRECTS = 5

  attr_reader :checked, :pages, :unreadable

  def initialize(base_url, fetcher: SiteCrawl::Fetcher.new(user_agent: 'kleer-site-headings'), logger: nil)
    @base = URI.parse(base_url)
    @fetcher = fetcher
    @logger = logger
    @checked = 0
    @pages = {}
    @unreadable = []
  end

  def run
    urls.each do |url|
      @logger&.call(url)
      body, final_url = read(url)
      next @unreadable << url if body.nil?

      @checked += 1
      problems = HeadingOutline.new(body.dup.force_encoding('UTF-8')).problems
      @pages[final_url] = problems if problems.any?
    end
    self
  end

  def urls
    sitemap, = @fetcher.page(on_base('/sitemap.xml'))
    sitemap.to_s.scan(%r{<loc>([^<]+)</loc>}).flatten.map { on_base(URI.parse(_1.strip).request_uri) }
  end

  def report
    lines = ["#{@checked} pages checked, #{@pages.size} with heading problems", '']
    lines += summary
    lines += ['', "Could not read: #{@unreadable.join(', ')}"] if @unreadable.any?
    @pages.each do |url, problems|
      lines += ['', url, *problems.map { "  #{_1}" }]
    end
    lines.join("\n")
  end

  private

  # Pages and problems per section, the first two segments of the path
  # (/es/blog), which is where a template's problem shows up.
  def summary
    @pages.group_by { |url, _| URI.parse(url).path.split('/').reject(&:empty?).first(2).join('/') }
          .sort_by { |_, pages| -pages.size }
          .map do |section, pages|
            format('%-20<section>s %4<pages>d pages %5<problems>d problems',
                   section: "/#{section}", pages: pages.size, problems: pages.sum { _2.size })
          end
  end

  def read(url, hops = MAX_REDIRECTS)
    body, = @fetcher.page(url)
    return [body, url] if body

    status, location = @fetcher.status(url)
    return [nil, url] unless location && status.to_s.start_with?('3') && hops.positive?

    read(URI.join(url, location).to_s, hops - 1)
  end

  def on_base(path)
    URI.join(@base, path).to_s
  end
end
