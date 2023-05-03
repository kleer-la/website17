require 'rubygems'
require 'bundler'

Bundler.require

require './app'
run Sinatra::Application
use Rack::Csrf, raise: true
