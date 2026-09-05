require 'spec_helper'
require './app'

# L'Atelier is one page on its own subdomain, in one language. It used to
# declare www.kleer.la/es and www.kleer.la/en as its language versions — pages
# on a different site, which is not what an alternate means — and it answered
# under both /es/ and /en/ with the same content, each canonical to itself.
describe "L'Atelier tells search engines what it is" do
  def app
    Sinatra::Application.new
  end

  let(:latelier_host) { { 'HTTP_HOST' => 'latelier.kleer.la' } }

  it 'claims no language alternates on the main site' do
    get '/es/', {}, latelier_host

    expect(last_response.body).not_to include('hreflang')
    expect(last_response.body).not_to include('https://www.kleer.la/en/')
  end

  it 'points both language paths at one canonical URL' do
    get '/en/', {}, latelier_host
    english = last_response.body

    get '/es/', {}, latelier_host
    spanish = last_response.body

    expect(english).to include('<link rel="canonical" href="https://latelier.kleer.la/es/"/>')
    expect(spanish).to include('<link rel="canonical" href="https://latelier.kleer.la/es/"/>')
  end
end
