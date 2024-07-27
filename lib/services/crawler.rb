require 'nokogiri'
require 'uri'

class Crawler
  attr_reader :errors, :checked_urls, :external_urls

  def initialize(base_url, max_depth = 3)
    @base_url = base_url
    @max_depth = max_depth
    @checked_urls = {}
    @external_urls = {}
    @errors = []
    @counter = 0
  end

  def execute(start_path = '/')
    crawl(start_path)
    save_results_to_file
    @errors
  end

  def save_results_to_file
    timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
    filename = "crawler_results_#{timestamp}.txt"
    File.open(filename, 'w') do |file|
      file.puts 'URLs crawled:'
      @checked_urls.each { |url, parent| file.puts "#{url}\t#{parent}" }
      file.puts "\nExternal URLs:"
      @external_urls.each { |url, parent| file.puts "#{url}\t#{parent}" }
    end
    puts "Results saved to #{filename}"
  end

  def filter_checked_urls(&condition)
    @checked_urls.select { |url, _| condition.call(url) }
  end

  def internal_url?(url)
    uri = URI(url)
    base_uri = URI(@base_url)

    return true if uri.host.nil?

    uri.host.sub(/^www\./, '') == base_uri.host.sub(/^www\./, '')
  rescue URI::InvalidURIError => e
    puts "Invalid URI: #{e.message}"
    false
  end

  private

  def complete_url(path)
    if path.start_with?('http://', 'https://')
      path # It's already a full URL
    else
      URI.join(@base_url, path).to_s
    end
  end

  def crawl(path, depth = 0, parent_url = nil)
    return if path.nil?

    full_url = complete_url(path)

    return if @checked_urls.key?(full_url) || depth > @max_depth

    @checked_urls[full_url] = parent_url
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
      next if href.nil? || href.empty? || href.start_with?('#')

      begin
        target_url = complete_url(href)
        is_internal = internal_url?(target_url)
        is_unchecked = !@checked_urls.key?(target_url)

        if is_internal && is_unchecked
          crawl(URI(target_url).path, depth + 1, current_url)
        else
          @external_urls[target_url] = current_url unless is_internal || @external_urls.key?(target_url)
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

  def get(path)
    raise NotImplementedError, "The 'get' method must be implemented"
  end
end
