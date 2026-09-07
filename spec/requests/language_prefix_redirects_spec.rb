require 'spec_helper'
require './app'

# The English slug without a prefix served the Spanish page: /services answered
# 200 with <html lang="es"> and canonicalised to /es/servicios. A section names
# its own language, so it can answer under its own prefix and nowhere else.
describe 'a section asked for without its language prefix' do
  def app
    Sinatra::Application.new
  end

  before do
    allow(Page).to receive(:load_from_keventer).and_return(Page.new)
    allow(Resource).to receive(:create_list_keventer).and_return([])
  end

  it 'sends an English section to the English prefix' do
    get '/services'

    expect(last_response.status).to eq(301)
    expect(last_response.location).to end_with('/en/services')
  end

  it 'sends a Spanish section to the Spanish prefix' do
    get '/recursos'

    expect(last_response.status).to eq(301)
    expect(last_response.location).to end_with('/es/recursos')
  end

  it 'sends a section that is the same in both languages to Spanish' do
    get '/blog'

    expect(last_response.status).to eq(301)
    expect(last_response.location).to end_with('/es/blog')
  end

  # Thirteen of the old redirects start with a section the table knows. Putting
  # the prefix on first would leave them resolving in two hops instead of one,
  # which is the shape #402 and #403 were about removing.
  it 'leaves an old redirect resolving in one hop' do
    get '/clientes/afp-crecer'

    expect(last_response.status).to eq(301)
    expect(last_response.location).to end_with('/es/blog/afp-crecer')
  end

  it 'leaves the membership redirect resolving in one hop' do
    get '/servicios/adopcion-ia/membresia'

    expect(last_response.status).to eq(301)
    expect(last_response.location).to end_with('/es/formacion/adopcion-ia-empresas')
  end

  it 'does not touch a utility route' do
    get '/robots.txt'

    expect(last_response.status).to eq(200)
  end

  it 'does not send a prefixed path around again' do
    get '/es/recursos'

    expect(last_response.status).to eq(200)
  end
end
