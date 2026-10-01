require 'spec_helper'
require './app'
require 'json'
require 'nokogiri'

# Search engines and AI answer engines build the organisation's card from the
# Organization JSON-LD (#441): it says who Kleer is, in the page's language,
# with every official profile and how to reach it.
describe 'the organisation in every page' do
  include Rack::Test::Methods

  def app
    Sinatra::Application.new
  end

  before do
    allow(Page).to receive(:load_from_keventer).and_return(Page.new)
    allow(Trainer).to receive(:create_keventer_json).and_return([])
  end

  def json_ld(type)
    Nokogiri::HTML(last_response.body).css('script[type="application/ld+json"]')
            .map { |s| JSON.parse(s.text) }.find { |d| d['@type'] == type }
  end

  def meta(property)
    Nokogiri::HTML(last_response.body).at_css("meta[property=\"#{property}\"], meta[name=\"#{property}\"]")
  end

  it 'describes Kleer in Spanish, with its profiles, address and contact' do
    get '/es/somos'

    org = json_ld('Organization')
    expect(org['description']).to include('Cocreamos el futuro del trabajo sin recetas')
    expect(org['sameAs']).to include('https://www.instagram.com/kleer.la/', 'https://www.linkedin.com/company/kleer/',
                                     'https://www.youtube.com/channel/UCAIGRA-4HRyx0fUUM9cjvQw',
                                     'https://x.com/kleer_la', 'https://www.facebook.com/kleer.la')
    expect(org['sameAs'].join).not_to include('klaborativa')
    expect(org['address']).to include('@type' => 'PostalAddress', 'addressCountry' => 'AR')
    expect(org['contactPoint']).to include('email' => 'info@kleer.la')
    expect(org['foundingDate']).to eq('2009-07')
    expect(org['areaServed']).to eq([{ '@type' => 'Place', 'name' => 'Latinoamérica' },
                                     { '@type' => 'Country', 'name' => 'España' }])
  end

  it 'describes Kleer in English on an English page' do
    get '/en/about_us'

    expect(json_ld('Organization')['description']).to include('We co-create the future of work')
    expect(json_ld('Organization')['areaServed'].map { |a| a['name'] }).to eq(['Latin America', 'Spain'])
  end

  it 'names the X account the footer links to' do
    get '/es/somos'

    expect(meta('twitter:site')['content']).to eq('@kleer_la')
  end

  it 'offers the other locale only on a page that has the other language' do
    get '/es/somos'
    expect(meta('og:locale:alternate')['content']).to eq('en_US')
  end

  # The Spanish home had its title in English and said "más de 13 años" (#441).
  it 'titles and describes the Spanish home in Spanish' do
    allow(ServiceAreaV3).to receive(:try_create_list_keventer).and_return([])
    allow(Event).to receive(:create_keventer_json).and_return([])
    allow(Article).to receive(:create_list_keventer).and_return([])
    allow(Resource).to receive(:create_list_keventer).and_return([])

    get '/es/'

    title = Nokogiri::HTML(last_response.body).at_css('title').text
    expect(title).to include('consultoría y formación')
    expect(meta('description')['content']).to include('más de 17 años')
  end
end
