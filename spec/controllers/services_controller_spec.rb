require 'spec_helper'
require './app'

describe '/servicios' do
  include Rack::Test::Methods

  def app
    Sinatra::Application.new
  end

  it 'responds successfully for Spanish route' do
    get '/servicios'
    expect(last_response).to be_ok
  end
  it 'responds successfully / at the end' do
    get '/servicios/'
    expect(last_response).to be_ok
  end
end
