require 'rubygems'
require 'bundler'
# require 'rack/csrf'

Bundler.require

set :environment, :production

use Rack::Session::Cookie, :key => 'rack.session', :domain=> '.kleer.la', :path => '/', secret: ENV['CONTACT_US_SECRET']

require './app'
run Sinatra::Application

