source 'https://rubygems.org'
ruby '~> 3.3'

gem 'aws-sdk-s3'
gem 'curb'
gem 'escape_utils'
gem 'faraday'
gem 'httparty' # new way to connect to keventer (replace faraday / json)
gem 'i18n'
gem 'json'
gem 'money'
gem 'nokogiri' # for RedCarpet
gem 'oauth'
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
gem 'concurrent-ruby'

group :development do
  gem 'foreman', require: false
  gem 'i18n-tasks', require: false
  gem 'platform-api', require: false
  gem 'rerun', require: false
  gem 'rubocop', require: false
  gem 'ruby-lsp', require: false
end

group :development, :test do
  gem 'capybara'
  gem 'coveralls_reborn'
  gem 'cucumber'
  gem 'rack-test'
  gem 'rspec'
  gem 'rspec-html-matchers' # , '~> 0.9.4'
  gem 'simplecov'
  gem 'simplecov-lcov' # to generate LCOV output for coverall.io
end

gem 'rackup', '~> 2.1'
