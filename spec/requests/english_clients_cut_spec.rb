require 'spec_helper'
require './app'
require 'nokogiri'

# /en/clients opened with "Some testimonials from clients" and showed none: no
# cases, no testimonials, a figure and a button. The cases do not exist in
# English and will not soon, so /en is cut to what it has (#404): the page sends
# its visitors to About us, and nothing offers it any more.
describe 'the clients page has no English edition' do
  def app
    Sinatra::Application.new
  end

  before do
    CacheService.clear
    allow(Page).to receive(:load_from_keventer).and_return(Page.new)
    allow(Article).to receive(:create_list_keventer).and_return([])
    allow(Trainer).to receive(:create_keventer_json).and_return([])
    allow(ServiceAreaV3).to receive(:try_create_list_keventer).and_return([])
    allow(Catalog).to receive(:create_keventer_json).and_return(nil)
    allow(Resource).to receive(:create_list_keventer).and_return([])
    allow(Event).to receive(:create_keventer_json).and_return([])
  end

  after { CacheService.clear }

  it 'sends /en/clients to About us' do
    get '/en/clients'

    expect(last_response.status).to eq(301)
    expect(last_response.headers['Location']).to end_with('/en/about_us')
  end

  it 'leaves it out of the English menu and footer' do
    get '/en/about_us'

    expect(last_response.body).not_to match(%r{href=["']/en/clients["']})
  end

  it 'keeps the Spanish page, with Spanish as its only language' do
    get '/es/clientes'

    expect(last_response.status).to eq(200)
    expect(last_response.body).not_to include('hreflang="en"')
    expect(last_response.body).to include('hreflang="es" href="https://www.kleer.la/es/clientes"')
  end

  it 'switches from the Spanish page to About us' do
    get '/es/clientes'

    expect(last_response.body).to include('language-switcher" href="/en/about_us"')
  end

  it 'keeps it in the Spanish menu' do
    get '/es/somos'

    expect(last_response.body).to include('href="/es/clientes"')
  end

  it 'lists only the Spanish page in the sitemap' do
    get '/sitemap.xml'
    doc = Nokogiri::XML(last_response.body)
    doc.remove_namespaces!
    urls = doc.xpath('//url/loc').map(&:text)

    expect(urls).to include('https://www.kleer.la/es/clientes')
    expect(urls).not_to include('https://www.kleer.la/en/clients')
  end
end
