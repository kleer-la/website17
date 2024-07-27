require 'nokogiri'
require './lib/services/crawler'

Given('the site is crawled') do
  puts "Defined? #{defined?($crawler)} inicio"
  next unless defined?($crawler).nil?

  $crawler = Crawler.new('https://www.kleer.la', 5)
  puts "Defined? #{defined?($crawler)}"
  class << $crawler
    include Rack::Test::Methods
    def app
      Sinatra::Application
    end

    # def get(path)
    #   super(path)
    # end
  end
  $crawler.execute
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
