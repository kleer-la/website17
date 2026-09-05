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
end
