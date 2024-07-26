require 'nokogiri'
require './lib/services/crawler'

Given('the website is running') do
  # No need to start a server, the app is available in-process
end

When('I check all the links') do
  crawler = Crawler.new('https://www.kleer.la', 4)
  class << crawler
    include Rack::Test::Methods
    def app
      Sinatra::Application
    end

    # def get(path)
    #   super(path)
    # end
  end
  @errors = crawler.execute
end

Then('I should see no broken links') do
  if @errors.any?
    error_messages = @errors.map do |e|
      parent_info = e[:parent_url] ? " (found on #{e[:parent_url]})" : ''
      "#{e[:url]} - #{e[:error]}#{parent_info}"
    end.join("\n")
    raise "Broken links found:\n#{error_messages}"
  end
end
