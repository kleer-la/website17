require 'spec_helper'
require './app'

# /llms.txt: a curated index in Markdown for AI answer engines (#439) — who
# Kleer is and its main pages, only canonical URLs that answer 200.
describe 'GET /llms.txt' do
  include Rack::Test::Methods

  def app
    Sinatra::Application.new
  end

  def area(slug, lang, services: [], program: false)
    ServiceAreaV3.new.load_from_json(
      'slug' => slug, 'lang' => lang, 'name' => slug.tr('-', ' ').capitalize, 'is_training_program' => program,
      'summary' => '<div>Qué hacemos <b>acá</b></div>', 'services' => services
    )
  end

  let(:courses) do
    [{ 'event_type_id' => 1, 'slug' => '1-scrum', 'name' => 'Scrum', 'lang' => 'es', 'subtitle' => 'El marco' },
     { 'event_type_id' => 2, 'slug' => '2-oculto', 'name' => 'Oculto', 'lang' => 'es', 'noindex' => true },
     { 'event_type_id' => 3, 'slug' => '3-va-a-otro', 'name' => 'Redirige', 'lang' => 'es',
       'external_site_url' => '/es/servicios/otro' }]
  end

  before do
    allow(Page).to receive(:load_from_keventer).and_return(Page.new)
    allow(ServiceAreaV3).to receive(:try_create_list_keventer) do |programs = false|
      if programs
        [area('adopcion-ia-empresas', 'es', program: true)]
      else
        agentes = { 'slug' => 'agentes', 'name' => 'Agentes',
                    'subtitle' => '<h1>Productos con agentes</h1><div>Y más texto</div>' }
        [area('producto-digital', 'es', services: [agentes]),
         area('digital-product', 'en')]
      end
    end
    allow(Catalog).to receive(:create_keventer_json).and_return(Catalog.load_catalog_events(courses))
    allow(Resource).to receive(:create_list_keventer)
      .and_return(Resource.load_list([{ 'slug' => 'kartas', 'slug_en' => 'kards', 'title_es' => 'Kartas',
                                        'title_en' => 'Kards', 'description_es' => 'Unas cartas',
                                        'description_en' => 'Some cards' }]))
    get '/llms.txt'
  end

  it 'answers plain text in UTF-8' do
    expect(last_response.status).to eq(200)
    expect(last_response.content_type).to eq('text/plain;charset=utf-8')
  end

  it 'opens with who Kleer is' do
    expect(last_response.body).to start_with("# Kleer\n\n> Cocreamos el futuro del trabajo sin recetas.")
  end

  it 'lists areas, services, programmes, courses and resources at their canonical URLs, in each language' do
    body = last_response.body
    expect(body).to include('- [Producto digital](https://www.kleer.la/es/servicios/producto-digital): ' \
                            'Qué hacemos acá')
    expect(body).to include('- [Agentes](https://www.kleer.la/es/servicios/producto-digital/agentes): ' \
                            'Productos con agentes')
    expect(body).to include('(https://www.kleer.la/es/formacion/adopcion-ia-empresas)')
    expect(body).to include('(https://www.kleer.la/en/services/digital-product)')
    expect(body).to include('- [Scrum](https://www.kleer.la/es/cursos/1-scrum): El marco')
    expect(body).to include('(https://www.kleer.la/es/recursos/kartas)', '(https://www.kleer.la/en/resources/kards)')
  end

  it "says a service with its subtitle's heading, as its card does" do
    expect(last_response.body).not_to include('Y más texto')
  end

  it 'leaves out noindex courses and courses that redirect' do
    expect(last_response.body).not_to include('2-oculto', '3-va-a-otro')
  end
end
