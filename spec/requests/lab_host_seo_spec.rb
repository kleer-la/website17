require 'spec_helper'
require './app'

# The lab. host serves Kleer Lab and nothing else (#442): kleer.la's pages do
# not exist here, a language prefix or a trailing slash goes to the bare path, its
# 404 is its own, the thank-you page stays out of the index, and the cases
# have an index page of their own.
describe 'the lab host keeps to Kleer Lab' do
  include Rack::Test::Methods

  def app
    Sinatra::Application.new
  end

  let(:lab) { { 'HTTP_HOST' => 'lab.kleer.la' } }

  before do
    allow_any_instance_of(Sinatra::Application).to receive(:recaptcha_tags).and_return('')
  end

  def slug = LabCase.published.first.slug

  # They have nothing to do with Lab: they do not exist here (#442).
  it "answers kleer.la's pages with Lab's own 404" do
    %w[/es/servicios /es/blog/un-articulo /en/catalog].each do |path|
      get path, {}, lab
      expect(last_response.status).to eq(404), path
      expect(last_response.body).to include('<meta name="application-name" content="Kleer Lab">'), path
    end
  end

  it 'sends a language prefix to the bare Lab path' do
    { '/es/' => '/', '/en' => '/', '/es/contacto' => '/contacto', "/en/casos/#{slug}" => "/casos/#{slug}" }
      .each do |asked, bare|
        get asked, {}, lab
        expect(last_response.status).to eq(301), asked
        expect(URI(last_response.location).path).to eq(bare), asked
      end
  end

  it 'sends a trailing slash to the path without it' do
    get "/casos/#{slug}/", {}, lab
    expect(last_response.status).to eq(301)
    expect(URI(last_response.location).path).to eq("/casos/#{slug}")
  end

  it 'answers a missing case with its own 404' do
    get '/casos/no-existe', {}, lab

    expect(last_response.status).to eq(404)
    expect(last_response.body).to include('<meta name="application-name" content="Kleer Lab">')
  end

  it 'keeps the thank-you page out of the index' do
    get '/contacto/gracias', {}, lab

    expect(last_response.body).to include('<meta name="robots" content="noindex">')
  end

  it 'lists the cases on /casos, which the sitemap names with every lastmod' do
    get '/casos', {}, lab
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include(%(href="/casos/#{slug}"))

    get '/sitemap.xml', {}, lab
    expect(last_response.body).to include('lab.kleer.la/casos</loc>')
    expect(last_response.body.scan('<url>').size).to eq(last_response.body.scan('<lastmod>').size)
  end

  it 'leaves the Lab pages and the contact form alone' do
    get '/', {}, lab
    expect(last_response.status).to eq(200)
    get '/contacto', {}, lab
    expect(last_response.status).to eq(200)
  end

  # A crawler's file sets no session: nothing on it needs one (#442).
  it 'sets no session cookie on robots.txt, sitemap.xml and llms.txt' do
    %w[/robots.txt /sitemap.xml /llms.txt].each do |path|
      get path, {}, lab
      expect(last_response.headers['Set-Cookie']).to be_nil, path
    end
  end

  it 'gives Kleer Lab an llms.txt of its own' do
    get '/llms.txt', {}, lab

    expect(last_response.content_type).to eq('text/plain;charset=utf-8')
    expect(last_response.body).to start_with("# Kleer Lab\n\n> ")
    expect(last_response.body).to include("(https://lab.kleer.la/casos/#{slug})", '(https://lab.kleer.la/contacto)')
    expect(last_response.body).to include('(https://www.kleer.la)')
  end
end
