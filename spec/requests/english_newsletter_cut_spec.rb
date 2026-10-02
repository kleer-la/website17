require 'spec_helper'
require './app'

# The newsletter is written in Spanish, and there is none in English. The
# footer already offered it only in Spanish, but its form still went into every
# English page, hidden, and the download form of a resource asked English
# readers whether to subscribe them to it (#404).
describe 'the newsletter is offered only in Spanish' do
  include Rack::Test::Methods

  def app
    Sinatra::Application.new
  end

  let(:doc) do
    { 'id' => 3, 'slug' => 'kards', 'format' => 'card', 'title_es' => 'Kartas', 'title_en' => 'Kards',
      'description_es' => 'Unas cartas', 'description_en' => 'Some cards', 'recommended' => [],
      # Something to download, or the page has no download form at all.
      'getit_es' => 'https://example.com/kartas.pdf', 'getit_en' => 'https://example.com/kards.pdf' }
  end

  before do
    allow(Page).to receive(:load_from_keventer).and_return(Page.new)
    allow(Resource).to receive(:create_one_keventer) { |_slug, lang| Resource.new(doc, lang) }
  end

  it 'does not ask English readers of a resource to subscribe' do
    get '/en/resources/kards'

    expect(last_response.status).to eq(200)
    expect(last_response.body).to include('name="can_we_contact"')
    expect(last_response.body).not_to include('name="suscribe"')
  end

  it 'still asks Spanish readers' do
    get '/es/recursos/kards'

    expect(last_response.body).to include('name="suscribe"')
  end

  it 'leaves the subscription form out of English pages' do
    get '/en/resources/kards'

    expect(last_response.body).not_to include('Suscríbete')
  end

  it 'keeps it in Spanish pages' do
    get '/es/recursos/kards'

    expect(last_response.body).to include('Suscríbete')
  end
end
