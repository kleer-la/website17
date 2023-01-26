require 'coveralls'
Coveralls.wear!

require 'simplecov'
SimpleCov.start
SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter

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
end

Capybara.app = Sinatra::Application

World { MyWorld.new }

# Capybara.register_driver :rack_test do |app|
# 	Capybara::RackTest::Driver.new(app, headers: { 'HTTP_USER_AGENT' => 'Capybara' })
# end

# Webrat.configure do |config|
# 	config.mode = :rack
# end

# class MyWorld
# 	include Rack::Test::Methods
# 	include Webrat::Methods
# 	include Webrat::Matchers

# 	Webrat::Methods.delegate_to_session :response_code, :response_body

# 	def app
# 		Sinatra::Application
# 	end
# end

# World{MyWorld.new}
