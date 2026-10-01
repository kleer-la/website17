require 'spec_helper'
require './app'
require 'json'
require 'nokogiri'

# A concepts resource is a glossary: a map of stages and one card per concept,
# each card at its own URL so it can be found and linked on its own.
describe 'a resource of the concepts format' do
  include Rack::Test::Methods

  def app
    Sinatra::Application.new
  end

  let(:doc) { JSON.parse(File.read('./spec/fixtures/resource_concepts.json')) }

  before do
    allow(Resource).to receive(:create_one_keventer).with('conceptos-de-ia', 'es')
                                                    .and_return(Resource.new(doc, 'es'))
    allow(Resource).to receive(:create_one_keventer).with('conceptos-de-ia', 'en')
                                                    .and_return(Resource.new(doc, 'en'))
  end

  def html
    Nokogiri::HTML(last_response.body)
  end

  def json_ld_of_type(type)
    html.css('script[type="application/ld+json"]').map { |s| JSON.parse(s.text) }.find { |d| d['@type'] == type }
  end

  describe 'the resource page' do
    before { get '/es/recursos/conceptos-de-ia' }

    it 'shows the map: every concept a real link to its page, grouped by stage' do
      expect(last_response.status).to eq(200)
      stages = html.css('.concepts-map .concepts-stage')
      expect(stages.map { |s| s.at_css('h2').text.strip }).to eq(['1Cómo se fabrica', '2Qué pasa cuando le escribís',
                                                                  '3Cómo se pone a trabajar'])
      links = html.css('.concepts-map a.concepts-item').map { |a| a['href'] }
      expect(links).to eq(%w[/es/recursos/conceptos-de-ia/datos /es/recursos/conceptos-de-ia/modelo
                             /es/recursos/conceptos-de-ia/token /es/recursos/conceptos-de-ia/agente])
    end

    it 'welcomes the reader with a way to start at the beginning' do
      welcome = html.at_css('.concepts-welcome')
      expect(welcome.text).to include('Elige una pregunta del mapa')
      expect(welcome.at_css('a')['href']).to eq('/es/recursos/conceptos-de-ia/datos')
    end

    it 'tells a phone reader to tap a question' do
      expect(html.at_css('.concepts-howto').text).to include('Toca la pregunta')
    end

    it 'keeps the long description as an optional intro' do
      expect(html.at_css('.concepts-intro').inner_html).to include('<strong>opcional</strong>')
    end

    it 'puts the download form after the concepts' do
      body = last_response.body
      expect(body.index('id="download-form"')).to be > body.index('concepts-map')
    end

    it 'describes itself as a set of defined terms' do
      set = json_ld_of_type('DefinedTermSet')
      expect(set['name']).to eq('Conceptos de IA sin jerga')
      expect(set['url']).to eq('https://www.kleer.la/es/recursos/conceptos-de-ia')
      expect(set['hasDefinedTerm'].map { |t| t['url'] })
        .to include('https://www.kleer.la/es/recursos/conceptos-de-ia/token')
      expect(set['hasDefinedTerm'].first).to include('@type' => 'DefinedTerm', 'name' => 'Datos de entrenamiento')
    end
  end

  describe 'a concept page' do
    before { get '/es/recursos/conceptos-de-ia/token' }

    it 'shows the card: stage, name, question and every part' do
      expect(last_response.status).to eq(200)
      card = html.at_css('.concepts-card')
      expect(card.at_css('.concepts-eyebrow').text).to include('Etapa 2', 'Qué pasa cuando le escribís')
      expect(card.at_css('h1').text).to eq('Token')
      expect(card.at_css('.concepts-question').text).to eq('¿Qué es un token?')
      expect(card.at_css('.concepts-definition').text).to include('La unidad en que el modelo lee y escribe.')
      expect(card.at_css('.concepts-media .toks span')).not_to be_nil
      expect(card.text).to include('Una imagen para recordarlo', 'Analogía de Token.')
      expect(card.at_css('.concepts-wrong').text).to eq('Malentendido de Token.')
      expect(card.text).to include('Corrección de Token.', 'Qué cambia en la práctica', 'Práctica de Token.')
    end

    it 'links the related concepts that exist, and leaves the missing ones out' do
      related = html.css('.concepts-related a').map { |a| a['href'] }
      expect(related).to eq(['/es/recursos/conceptos-de-ia/modelo'])
    end

    it 'links the previous and next concepts' do
      expect(html.at_css('.concepts-nav a.prev')['href']).to eq('/es/recursos/conceptos-de-ia/modelo')
      expect(html.at_css('.concepts-nav a.next')['href']).to eq('/es/recursos/conceptos-de-ia/agente')
    end

    it 'gives a phone reader the way back to the map and where they are' do
      bar = html.at_css('.concepts-topbar')
      expect(bar.at_css('a')['href']).to eq('/es/recursos/conceptos-de-ia')
      expect(bar.text).to include('← Mapa', '3 de 4')
    end

    it 'marks the concept as the one open in the map' do
      expect(html.at_css('.concepts-map a.concepts-item.on')['href']).to eq('/es/recursos/conceptos-de-ia/token')
    end

    it 'is its own page for search engines' do
      expect(html.at_css('title').text).to include('¿Qué es un token? · Conceptos de IA sin jerga')
      expect(html.at_css('meta[name="description"]')['content']).to eq('La unidad en que el modelo lee y escribe.')
      expect(html.at_css('link[rel="canonical"]')['href'])
        .to eq('https://www.kleer.la/es/recursos/conceptos-de-ia/token')
    end

    it 'escapes quotes in its title' do
      get '/es/recursos/conceptos-de-ia/modelo'

      expect(html.at_css('meta[property="og:title"]')['content'])
        .to eq('¿Qué es exactamente "la IA"? · Conceptos de IA sin jerga')
    end

    it 'describes itself as a defined term of the set' do
      term = json_ld_of_type('DefinedTerm')
      expect(term).to include('name' => 'Token', 'description' => 'La unidad en que el modelo lee y escribe.',
                              'url' => 'https://www.kleer.la/es/recursos/conceptos-de-ia/token')
      expect(term['inDefinedTermSet']).to include('@type' => 'DefinedTermSet',
                                                  'url' => 'https://www.kleer.la/es/recursos/conceptos-de-ia')
      # schema.org's validator warns on inLanguage: DefinedTerm is not a CreativeWork
      expect(term).not_to have_key('inLanguage')
    end

    it 'does not offer the download form in the card page hero' do
      expect(html.at_css('#resource-detail-hero')).to be_nil
    end
  end

  it 'answers 404 for a concept the resource does not have' do
    get '/es/recursos/conceptos-de-ia/nada'

    expect(last_response.status).to eq(404)
  end

  it 'answers 404 for a concept of a resource of another format' do
    allow(Resource).to receive(:create_one_keventer).with('conceptos-de-ia', 'es')
                                                    .and_return(Resource.new(doc.merge('format' => 'card'), 'es'))

    get '/es/recursos/conceptos-de-ia/token'

    expect(last_response.status).to eq(404)
  end

  it 'answers 404 when the resource has no concepts in that language' do
    get '/en/resources/conceptos-de-ia/token'

    expect(last_response.status).to eq(404)
  end

  it 'follows the resource to its current slug' do
    allow(Resource).to receive(:create_one_keventer).with('viejo', 'es').and_return(Resource.new(doc, 'es'))

    get '/es/recursos/viejo/token'

    expect(last_response.status).to eq(301)
    expect(last_response.location).to end_with('/es/recursos/conceptos-de-ia/token')
  end
end
