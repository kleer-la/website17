require 'coveralls'
Coveralls.wear!

require 'simplecov'
SimpleCov.start

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.syntax = [:expect, :should]
  end
  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end  
end