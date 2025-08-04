require 'coveralls'
Coveralls.wear!

require 'simplecov'
require 'simplecov-lcov'
SimpleCov.start
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
                                                                 SimpleCov::Formatter::HTMLFormatter,
                                                                 SimpleCov::Formatter::LcovFormatter
                                                               ])
ENV['RACK_ENV'] ||= 'test'

# Sinatra
require File.join(File.dirname(__FILE__), *%w[.. .. app])
# Force the application name because polyglot breaks the auto-detection logic.
Sinatra::Application.app_file = File.join(File.dirname(__FILE__), *%w[.. .. app.rb])

require 'rspec/expectations'
require 'cucumber/rspec/doubles'
require 'rack/test'
require 'capybara/cucumber'
require 'rspec-html-matchers'

class MyWorld
  include Capybara::DSL
  include RSpec::Expectations
  include RSpec::Matchers
  include RSpecHtmlMatchers
  include Rack::Test::Methods  # Add this line

  def app
    Sinatra::Application
  end
end

Capybara.app = Sinatra::Application
Capybara.default_driver = :rack_test

World { MyWorld.new }
