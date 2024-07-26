require 'nokogiri'
require 'uri'

class Crawler
  def initialize(base_url, max_depth = 3)
    @base_url = base_url
    @max_depth = max_depth
    @checked_urls = Set.new
    @errors = []
    @counter = 0
  end

  def execute(start_path = '/')
    crawl(start_path)
    @errors
  end

  # private

  def crawl(path, depth = 0, parent_url = nil)
    full_url = URI.join(@base_url, path).to_s

    return if @checked_urls.include?(full_url) || depth > @max_depth

    @checked_urls.add(full_url)
    @counter += 1
    puts "#{@counter}. Checking: #{full_url} (depth: #{depth})"

    begin
      response = get path
      check_response(full_url, response, parent_url)
      parse_links(full_url, response.body, depth) if response.status == 200
    rescue StandardError => e
      @errors << { url: full_url, error: e.message, parent_url: parent_url }
    end
  end

  def parse_links(current_url, body, depth)
    doc = Nokogiri::HTML(body)

    doc.css('a').each do |link|
      href = link['href']&.strip
      next if href.nil? || href.start_with?('#')

      begin
        target_url = URI.join(@base_url, href).to_s
        is_internal = internal_url?(target_url)
        is_unchecked = !@checked_urls.include?(target_url)

        if is_internal && is_unchecked
          puts "Crawling internal link: #{target_url}"
          crawl(URI(target_url).path, depth + 1, current_url)
        else
          reason = !is_internal ? 'external' : 'already checked'
          puts "Skipping link: #{target_url} (#{reason})"
        end
      rescue URI::InvalidURIError => e
        puts "Invalid URI: #{e.message}"
        @errors << { url: href, error: e.message, parent_url: current_url }
      end
    end
  end

  def check_response(url, response, parent_url)
    return unless response.status == 404 || response.status == 500

    @errors << { url: url, error: "HTTP #{response.status}", parent_url: parent_url }
  end

  def internal_url?(url)
    uri = URI(url)
    base_uri = URI(@base_url)

    # Check if the URL is relative (no host)
    if uri.host.nil?
      puts 'Relative URL, considering internal'
      return true
    end

    # Compare hosts, ignoring 'www' subdomain
    uri.host.sub(/^www\./, '') == base_uri.host.sub(/^www\./, '')
  rescue URI::InvalidURIError => e
    puts "Invalid URI: #{e.message}"
    false # If we can't parse the URL, assume it's not internal
  end

  def get(path)
    # This method should be implemented to make the actual HTTP request
    # For now, we'll leave it as a placeholder
    raise NotImplementedError, "The 'get' method must be implemented"
  end
end
