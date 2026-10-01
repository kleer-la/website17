require 'spec_helper'
require './app'
require 'json'
require 'nokogiri'

# A resource with an English slug of its own (kleer-la/eventer#227): the English
# listing links to it, and each language answers the other's slug with a 301
# to its own (#435). Equal slugs in both languages serve without redirecting.
describe 'a resource with an English slug' do
  include Rack::Test::Methods

  def app
    Sinatra::Application.new
  end

  let(:doc) do
    { 'id' => 3, 'slug' => 'kartas', 'slug_en' => 'agile-kards', 'format' => 'card',
      'title_es' => 'Kartas', 'title_en' => 'Kards', 'description_es' => 'Unas cartas',
      'description_en' => 'Some cards', 'recommended' => [] }
  end

  # What Keventer's show answers for each language: the slug of that language.
  def keventer_answers(doc)
    allow(Resource).to receive(:create_one_keventer) do |_slug, lang|
      Resource.new(doc.merge('slug' => lang.to_s == 'en' ? doc['slug_en'] || doc['slug'] : doc['slug']), lang)
    end
  end

  before do
    allow(Page).to receive(:load_from_keventer).and_return(Page.new)
    keventer_answers(doc)
  end

  it 'links the English card to the English slug and the Spanish one to the Spanish slug' do
    allow(Resource).to receive(:create_list_keventer).and_return(Resource.load_list([doc]))

    get '/en/resources'
    expect(Nokogiri::HTML(last_response.body).at_css('.resource-card a')['href']).to eq('/en/resources/agile-kards')

    get '/es/recursos'
    expect(Nokogiri::HTML(last_response.body).at_css('.resource-card a')['href']).to eq('/es/recursos/kartas')
  end

  it 'sends the Spanish slug under /en to the English one, and the other way round' do
    get '/en/resources/kartas'
    expect(last_response.status).to eq(301)
    expect(last_response.location).to end_with('/en/resources/agile-kards')

    get '/es/recursos/agile-kards'
    expect(last_response.status).to eq(301)
    expect(last_response.location).to end_with('/es/recursos/kartas')
  end

  it 'serves each language at its own slug' do
    get '/en/resources/agile-kards'
    expect(last_response.status).to eq(200)

    get '/es/recursos/kartas'
    expect(last_response.status).to eq(200)
  end

  it 'serves a resource whose two slugs are the same, in both languages' do
    keventer_answers(doc.merge('slug_en' => 'kartas'))

    get '/en/resources/kartas'
    expect(last_response.status).to eq(200)
    get '/es/recursos/kartas'
    expect(last_response.status).to eq(200)
  end

  it 'offers the other language at its own slug' do
    get '/en/resources/agile-kards'

    expect(last_response.body).to include('hreflang="es" href="https://www.kleer.la/es/recursos/kartas"')
  end
end
