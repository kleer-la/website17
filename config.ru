require 'rubygems'
require 'bundler'
require 'rack/csrf'

Bundler.require

use Rack::Csrf, raise: true

require './app'
run Sinatra::Application
# use Rack::Session::Cookie, secret: 'mi_clave_secreta'

