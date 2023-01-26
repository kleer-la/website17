require 'coveralls'
Coveralls.wear!

require 'simplecov'
SimpleCov.start
SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter


RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.syntax = %i[expect should]
  end
  config.mock_with :rspec do |c|
    c.syntax = %i[should expect]
  end
end
