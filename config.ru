require 'rubygems'
require 'bundler'

Bundler.require

set :environment, :production

require './app'
run Sinatra::Application

