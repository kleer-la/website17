require 'coveralls'
Coveralls.wear!

require 'simplecov'
require 'simplecov-lcov'
require 'rack/test'

SimpleCov.start
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
                                                                 SimpleCov::Formatter::HTMLFormatter,
                                                                 SimpleCov::Formatter::LcovFormatter
                                                               ])

RSpec.configure do |config|
  config.include Rack::Test::Methods  # post
end

