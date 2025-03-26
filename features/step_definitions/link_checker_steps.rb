require 'nokogiri'
require './lib/services/crawler'

Given('the site is crawled') do
  next unless defined?($crawler).nil?

  $crawler = Crawler.new('https://www.kleer.la', 5)
  class << $crawler
    include Rack::Test::Methods
    def app
      Sinatra::Application
    end

    # def get(path)
    #   super(path)
    # end
  end
  $crawler.execute('/es/blog')
end

Then 'Save the crawling results to {string}' do |filename|
  $crawler.save_results_to_file(filename)
end
Then 'Save the crawling results' do
  $crawler.save_results_to_file
end

Then('I should see no broken links') do
  if $crawler.errors.any?
    error_messages = $crawler.errors.map do |e|
      parent_info = e[:parent_url] ? " (found on #{e[:parent_url]})" : ''
      "#{e[:url]} - #{e[:error]}#{parent_info}"
    end.join("\n")
    raise "Broken links found:\n#{error_messages}"
  end
end

Then('No URL with double {string} prefix') do |lang|
  errors = $crawler.filter_checked_urls do |url|
    segments = url.split '/'
    segments.count(lang) > 1
  end

  raise " Duplcated /#{lang}: \n #{errors.join('\n')}" if errors.any?
end

Then('all external URLs should be valid') do
  invalid_urls = []
  skipped_urls = []

  $crawler.external_urls.each do |url, parent_url|
    if parent_url.end_with?('(POST form)')
      skipped_urls << "#{url} (Skipped: POST form, Parent: #{parent_url})"
      next
    end

    uri = URI(url)
    uri.path = '/' if uri.path.empty?

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request_head(uri.path)
    end
    next if [403, 405, 429, 999].include?(response.code.to_i)

    invalid_urls << "#{url} (Status: #{response.code}, Parent: #{parent_url})" if response.code.to_i >= 400
  rescue StandardError => e
    invalid_urls << "#{url} (Error: #{e.message}, Parent: #{parent_url})"
  end

  raise "The following external URLs are invalid:\n#{invalid_urls.join("\n")}" if invalid_urls.any?
end
