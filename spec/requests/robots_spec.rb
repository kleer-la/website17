require 'spec_helper'
require './app'

describe 'GET /robots.txt' do
  def app
    Sinatra::Application.new
  end

  before do
    get '/robots.txt'
  end

  it 'returns 200 with text content type' do
    expect(last_response.status).to eq(200)
    expect(last_response.content_type).to include('text/plain')
  end

  it 'allows all user agents' do
    expect(last_response.body).to include('User-agent: *')
  end

  it 'disallows apple-app-site-association paths' do
    expect(last_response.body).to include('Disallow: /.well-known/apple-app-site-association')
    expect(last_response.body).to include('Disallow: /apple-app-site-association')
  end

  it 'includes sitemap directive' do
    expect(last_response.body).to include('Sitemap: https://www.kleer.la/sitemap.xml')
  end
end
