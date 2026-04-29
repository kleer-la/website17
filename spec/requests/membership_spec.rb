require 'spec_helper'
require './app'

describe 'GET /membresia-ia' do
  def app
    Sinatra::Application.new
  end

  it 'returns 200 at /membresia-ia' do
    get '/membresia-ia'
    expect(last_response.status).to eq(200)
  end

  it 'returns 200 at /es/membresia-ia (locale-prefixed)' do
    get '/es/membresia-ia'
    expect(last_response.status).to eq(200)
  end

  it 'renders with noindex,nofollow robots meta' do
    get '/membresia-ia'
    expect(last_response.body).to include('<meta name="robots" content="noindex,nofollow"/>')
  end
end
