require 'rubygems'
require 'bundler'
require 'rack/csrf'

Bundler.require

use Rack::Session::Cookie, secret: ENV['CONTACT_US_SECRET']
use Rack::Csrf, raise: true

require './app'
run Sinatra::Application

