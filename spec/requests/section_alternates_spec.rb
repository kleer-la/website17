require 'spec_helper'
require './app'

# Sections whose slug is translated — somos/about_us, catalogo/catalog — cannot
# take the current path and swap the language prefix: that names /en/somos,
# which redirects to /en/about_us. An alternate pointing at a redirect is a pair
# Google never confirms, so the page loses its other language.
describe 'language alternates of a translated section' do
  def app
    Sinatra::Application.new
  end

  before do
    allow(Page).to receive(:load_from_keventer).and_return(Page.new)
    allow(Trainer).to receive(:create_keventer_json).and_return([])
    allow(Resource).to receive(:create_list_keventer).and_return([])
    allow(News).to receive(:create_list_keventer).and_return([])
    allow(Article).to receive(:create_list_keventer).and_return([])
    allow(Podcast).to receive(:load_from_keventer).and_return([])
  end

  it 'names each language slug on Quiénes somos' do
    get '/es/somos'

    expect(last_response.body).to include('hreflang="es" href="https://www.kleer.la/es/somos"')
    expect(last_response.body).to include('hreflang="en" href="https://www.kleer.la/en/about_us"')
    expect(last_response.body).not_to include('/en/somos"')
  end

  it 'does the same from the English side' do
    get '/en/about_us'

    expect(last_response.body).to include('hreflang="es" href="https://www.kleer.la/es/somos"')
    expect(last_response.body).to include('hreflang="en" href="https://www.kleer.la/en/about_us"')
  end

  # The sections that do not spell their alternates out fall back to the current
  # path with the prefix swapped, which names the Spanish segment under /en.
  it 'translates the section of the resources index' do
    get '/es/recursos'

    expect(last_response.body).to include('hreflang="en" href="https://www.kleer.la/en/resources"')
    expect(last_response.body).not_to include('hreflang="en" href="https://www.kleer.la/en/recursos"')
  end

  it 'translates the section from the English side' do
    get '/en/resources'

    expect(last_response.body).to include('hreflang="es" href="https://www.kleer.la/es/recursos"')
    expect(last_response.body).not_to include('hreflang="es" href="https://www.kleer.la/es/resources"')
  end

  it 'translates clientes' do
    get '/es/clientes'

    expect(last_response.body).to include('hreflang="en" href="https://www.kleer.la/en/clients"')
    expect(last_response.body).not_to include('hreflang="en" href="https://www.kleer.la/en/clientes"')
  end

  # A section that is the same URL in both languages has a working alternate
  # already; translating a table it is not in would be how that gets lost.
  # Podcasts used to be the example here and is Spanish-only now, so the case
  # rides on /privacy — the other section the table does not know.
  it 'leaves a section that is not translated alone' do
    get '/es/privacy'

    expect(last_response.body).to include('hreflang="es" href="https://www.kleer.la/es/privacy"')
    expect(last_response.body).to include('hreflang="en" href="https://www.kleer.la/en/privacy"')
  end
end
