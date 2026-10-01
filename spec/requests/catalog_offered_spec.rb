require 'spec_helper'
require './app'
require 'nokogiri'

# The English catalogue is down to a course or two, and the course cut leaves it
# empty (#421). An empty /en/catalog is a page that promises courses and lists
# none, offered from the menu, the footer, the language switcher and the
# sitemap. Whether a language has a catalogue is read from the courses
# Keventer sends, so the entries come back on their own with the first one.
describe 'the catalogue in a language with no courses' do
  def app
    Sinatra::Application.new
  end

  def course(lang:, slug:, noindex: false)
    Event.new(EventType.new({ 'id' => slug.hash.abs, 'slug' => slug, 'name' => slug,
                              'lang' => lang, 'deleted' => false, 'noindex' => noindex,
                              'categories' => [] }))
  end

  let(:spanish_course) { course(lang: 'es', slug: 'scrum-master') }
  let(:catalog) { [spanish_course] }

  before do
    CacheService.clear
    allow(Page).to receive(:load_from_keventer).and_return(Page.new)
    allow(Event).to receive(:create_keventer_json).and_return([])
    allow(ServiceAreaV3).to receive(:try_create_list_keventer).and_return([])
    allow(Category).to receive(:create_keventer_json).and_return([])
    allow(Article).to receive(:create_list_keventer).and_return([])
    allow(Resource).to receive(:create_list_keventer).and_return([])
    allow(Catalog).to receive(:create_keventer_json).and_return(catalog)
  end

  after { CacheService.clear }

  def sitemap_urls
    get '/sitemap.xml'
    doc = Nokogiri::XML(last_response.body)
    doc.remove_namespaces!
    doc.xpath('//url/loc').map(&:text)
  end

  shared_examples 'no English catalogue' do
    # 302, not 301: the page comes back with the first English course, and a
    # permanent redirect is one a browser and a crawler remember.
    it 'sends /en/catalog to the services, for now' do
      get '/en/catalog'

      expect(last_response.status).to eq(302)
      expect(last_response.headers['Location']).to end_with('/en/services')
    end

    it 'leaves it out of the English menu and footer' do
      get '/en/services'

      expect(last_response.body).not_to include('href="/en/catalog"')
      expect(last_response.body).not_to include("href='/en/catalog'")
    end

    it 'does not offer it as the English version of the Spanish one' do
      get '/es/catalogo'

      expect(last_response.status).to eq(200)
      expect(last_response.body).not_to include('hreflang="en"')
      expect(last_response.body).not_to include('href="/en/catalog"')
    end

    it 'does not switch to it from the Spanish agenda' do
      get '/es/agenda'

      expect(last_response.body).not_to include('href="/en/catalog"')
    end

    it 'leaves it out of the sitemap' do
      expect(sitemap_urls).not_to include('https://www.kleer.la/en/catalog')
      expect(sitemap_urls).to include('https://www.kleer.la/es/catalogo')
    end
  end

  context 'when every course is in Spanish' do
    it_behaves_like 'no English catalogue'
  end

  # A noindex course is not what the catalogue is there to offer: a menu entry
  # leading to a page whose only course asks not to be indexed is still empty.
  context 'when the only English course is noindex' do
    let(:catalog) { [spanish_course, course(lang: 'en', slug: '414-agile-products-with-scrum', noindex: true)] }

    it_behaves_like 'no English catalogue'
  end

  context 'when there is an English course' do
    let(:catalog) { [spanish_course, course(lang: 'en', slug: '68-certified-scrum-master-csm')] }

    it 'serves /en/catalog' do
      get '/en/catalog'

      expect(last_response.status).to eq(200)
    end

    it 'offers it in the English menu and footer' do
      get '/en/services'

      expect(last_response.body).to include('href="/en/catalog"')
      expect(last_response.body).to include("href='/en/catalog'")
    end

    it 'pairs it with the Spanish one' do
      get '/es/catalogo'

      expect(last_response.body).to include('hreflang="en" href="https://www.kleer.la/en/catalog"')
    end

    it 'lists it in the sitemap' do
      expect(sitemap_urls).to include('https://www.kleer.la/en/catalog')
    end
  end

  # The catalogue answers nil when Keventer does not. A hiccup there is no
  # reason to take the section off the site for as long as the cache holds it.
  context 'when Keventer does not answer' do
    let(:catalog) { nil }

    it 'keeps serving /en/catalog' do
      get '/en/catalog'

      expect(last_response.status).to eq(200)
    end
  end

  # The menu and the footer ask on every page: a request that raises cannot be
  # allowed to take the page down with it.
  context 'when the request to Keventer raises' do
    before do
      allow(Catalog).to receive(:create_keventer_json).and_raise(Faraday::ConnectionFailed, 'down')
    end

    it 'still serves the other pages, with the catalogue in the menu' do
      get '/en/services'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('href="/en/catalog"')
    end
  end

  it 'keeps the Spanish catalogue in the Spanish menu' do
    get '/es/servicios'

    expect(last_response.body).to include('href="/es/catalogo"')
  end
end
