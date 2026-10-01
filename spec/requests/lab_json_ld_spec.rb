require 'spec_helper'
require './app'
require 'json'
require 'nokogiri'

# What search and AI answer engines read about Kleer Lab (#442).
describe 'Kleer Lab structured data' do
  include Rack::Test::Methods

  def app
    Sinatra::Application.new
  end

  let(:lab) { { 'HTTP_HOST' => 'lab.kleer.la' } }

  def json_ld(type)
    Nokogiri::HTML(last_response.body).css('script[type="application/ld+json"]')
            .map { |s| JSON.parse(s.text) }.find { |d| d['@type'] == type }
  end

  it 'says on the home what Kleer Lab is, where it works, how to reach it and whose it is' do
    get '/', {}, lab

    expect(json_ld('WebSite')).to include('name' => 'Kleer Lab', 'url' => 'https://lab.kleer.la/')
    org = json_ld('Organization')
    expect(org['parentOrganization']).to include('name' => 'Kleer')
    expect(org['areaServed'].map { |a| a['name'] }).to eq(%w[Latinoamérica España])
    expect(org['contactPoint']).to include('url' => 'https://lab.kleer.la/contacto')
    expect(json_ld('ProfessionalService')).to include('name' => 'Kleer Lab', 'url' => 'https://lab.kleer.la/')
  end

  it 'describes a case as an article about its client, with an image and its own page' do
    kase = LabCase.published.first
    get "/casos/#{kase.slug}", {}, lab

    article = json_ld('Article')
    expect(article['image']).to start_with('https://lab.kleer.la/')
    expect(article['about']).to include('@type' => 'Organization', 'name' => kase.client_name)
    expect(article['mainEntityOfPage']).to eq("https://lab.kleer.la/casos/#{kase.slug}")
    crumbs = json_ld('BreadcrumbList')['itemListElement']
    expect(crumbs.map { |c| c['item'] })
      .to eq(['https://lab.kleer.la/', 'https://lab.kleer.la/casos', "https://lab.kleer.la/casos/#{kase.slug}"])
  end
end
