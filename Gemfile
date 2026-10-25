source 'https://rubygems.org'
ruby '~> 4.0.9'

gem 'aws-sdk-s3'
gem 'concurrent-ruby'
gem 'curb'
gem 'escape_utils'
gem 'faraday'
gem 'httparty' # new way to connect to keventer (replace faraday / json)
gem 'i18n'
gem 'json'
gem 'money'
gem 'nokogiri' # for RedCarpet
gem 'ostruct' # FileStoreService requires it; no longer a default gem in Ruby 4.0
gem 'puma'
gem 'rack-ssl-enforcer'
gem 'rake'
gem 'recaptcha'
gem 'redcarpet'
gem 'sinatra'
gem 'sinatra-flash'
gem 'sinatra-r18n'
gem 'tzinfo'
gem 'tzinfo-data'

group :development do
  gem 'bundler-audit', require: false
  gem 'foreman', require: false
  gem 'i18n-tasks', require: false
  gem 'kamal', require: false
  gem 'platform-api', require: false
  gem 'rerun', require: false
  gem 'rubocop', require: false
  gem 'ruby-lsp', require: false
  gem 'sass'
end

group :development, :test do
  gem 'capybara'
  gem 'coveralls_reborn'
  gem 'cucumber', '~> 11.1' # 12 calls RSpec::Mocks.setup(arg), which rspec-mocks 3.13 rejects
  gem 'rack-test'
  gem 'rspec'
  gem 'rspec-html-matchers' # , '~> 0.9.4'
  gem 'simplecov'
  gem 'simplecov-lcov' # to generate LCOV output for coverall.io
end

gem 'rackup', '~> 2.3'
