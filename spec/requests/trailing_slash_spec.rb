require 'spec_helper'
require './app'

# One URL per page (#443): a trailing slash answers 301 to the URL without it,
# instead of 200 on some routes and 404 on others; the bare root goes to the
# Spanish home. /es/ and /en/ are the homes as the site links them, and stay.
describe 'trailing slashes and the root' do
  include Rack::Test::Methods

  def app
    Sinatra::Application.new
  end

  it 'sends a path with a trailing slash to the same path without it' do
    get '/es/servicios/'
    expect(last_response.status).to eq(301)
    expect(last_response.location).to end_with('/es/servicios')

    get '/es/servicios/cambio-organizacional-liderazgo/'
    expect(last_response.location).to end_with('/es/servicios/cambio-organizacional-liderazgo')
  end

  it 'keeps the query string' do
    get '/es/blog/?categoria=x'

    expect(last_response.location).to end_with('/es/blog?categoria=x')
  end

  it 'sends the root to the Spanish home' do
    get '/'

    expect(last_response.status).to eq(301)
    expect(last_response.location).to end_with('/es/')
  end

  it 'leaves the homes as they are' do
    allow(Page).to receive(:load_from_keventer).and_return(Page.new)
    allow(ServiceAreaV3).to receive(:try_create_list_keventer).and_return([])
    allow(Event).to receive(:create_keventer_json).and_return([])

    get '/es/'

    expect(last_response.status).not_to eq(301)
  end
end
