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
  config.include Rack::Test::Methods # post

  # Set RACK_ENV to test for clean test output
  ENV['RACK_ENV'] = 'test'

  # The performance specs run Lighthouse against a deployed site, so they
  # only run when told where: `rake perf[https://qa.kleer.la]`.
  config.filter_run_excluding :perf unless ENV['PERF_BASE_URL']
end
