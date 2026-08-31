#!/usr/bin/env ruby
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('Gemfile', __dir__)

require 'bundler'
Bundler.setup(:default)

require 'irb'
require 'irb/completion'

# Require your Sinatra app and dependencies
require_relative './app'

# Set up the IRB session
IRB.setup nil
IRB.conf[:MAIN_CONTEXT] = IRB::Irb.new.context

# Start IRB
IRB.start
