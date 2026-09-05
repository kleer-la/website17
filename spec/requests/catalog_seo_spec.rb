require 'spec_helper'
require './app'

# The catalogue has a slug per language — /es/catalogo and /en/catalog — and
# both of its own signals used to name the other language's slug: the English
# page canonicalised to /en/catalogo and offered /es/catalog as its Spanish
# version. Neither URL exists; both redirect. A canonical or an alternate that
# points at a redirect is a signal Google drops.
describe 'the catalogue tells search engines where it lives' do
  def app
    Sinatra::Application.new
  end

  before do
    allow(Catalog).to receive(:create_keventer_json).and_return([])
    allow(Category).to receive(:create_keventer_json).and_return([])
    allow(Page).to receive(:load_from_keventer).and_return(Page.new)
  end

  it 'canonicalises the English catalogue to its own URL' do
    get '/en/catalog'

    expect(last_response.body).to include('<link rel="canonical" href="https://www.kleer.la/en/catalog"/>')
  end

  it 'canonicalises the Spanish catalogue to its own URL' do
    get '/es/catalogo'

    expect(last_response.body).to include('<link rel="canonical" href="https://www.kleer.la/es/catalogo"/>')
  end

  it 'names each language version by the slug that language uses' do
    get '/en/catalog'

    expect(last_response.body).to include('hreflang="es" href="https://www.kleer.la/es/catalogo"')
    expect(last_response.body).to include('hreflang="en" href="https://www.kleer.la/en/catalog"')
  end

  it 'does the same from the Spanish side' do
    get '/es/catalogo'

    expect(last_response.body).to include('hreflang="es" href="https://www.kleer.la/es/catalogo"')
    expect(last_response.body).to include('hreflang="en" href="https://www.kleer.la/en/catalog"')
  end
end
