require 'spec_helper'
require './app'

# A service area exists in one language: the English areas are separate records
# with their own slugs, and nothing in the data links them to the Spanish ones.
# Declaring both built the alternate with the Spanish slug under /en — and for
# the training programmes, under /servicios, which does not exist at all.
describe 'language alternates of a service area' do
  def app
    Sinatra::Application.new
  end

  let(:area_data) do
    {
      'id' => 1,
      'slug' => 'adopcion-ia-empresas',
      'name' => 'Adopción de IA',
      'lang' => 'es',
      'is_training_program' => true,
      'primary_color' => '#FF5733',
      'primary_font_color' => '#FFFFFF',
      'secondary_color' => '#33FF57',
      'secondary_font_color' => '#000000',
      'services' => []
    }
  end

  before do
    allow(Page).to receive(:load_from_keventer).and_return(Page.new)
    ServiceAreaV3.null_json_api(nil, NullJsonAPI.new(nil, area_data.to_json))
  end

  after do
    ServiceAreaV3.class_variable_set(:@@json_api, nil) if ServiceAreaV3.class_variable_defined?(:@@json_api)
  end

  it 'names its own section, not the services one' do
    get '/es/formacion/adopcion-ia-empresas'

    expect(last_response.body)
      .to include('hreflang="es" href="https://www.kleer.la/es/formacion/adopcion-ia-empresas"')
    expect(last_response.body).not_to include('/servicios/adopcion-ia-empresas')
    expect(last_response.body).not_to include('/services/adopcion-ia-empresas')
  end

  it 'declares the language it has and no other' do
    get '/es/formacion/adopcion-ia-empresas'

    expect(last_response.body).not_to include('hreflang="en"')
  end

  it 'canonicalises to its own section' do
    get '/es/formacion/adopcion-ia-empresas'

    expect(last_response.body)
      .to include('<link rel="canonical" href="https://www.kleer.la/es/formacion/adopcion-ia-empresas"/>')
  end

end

# The service routes, unlike the training ones, do not check the area's language
# before rendering, so an area that declares none has to render anyway.
describe 'a service area that does not declare a language' do
  def app
    Sinatra::Application.new
  end

  let(:area_data) do
    {
      'id' => 3,
      'slug' => 'chaos-control',
      'name' => 'Chaos control',
      'is_training_program' => false,
      'primary_color' => '#FF5733',
      'primary_font_color' => '#FFFFFF',
      'secondary_color' => '#33FF57',
      'secondary_font_color' => '#000000',
      'services' => []
    }
  end

  before do
    allow(Page).to receive(:load_from_keventer).and_return(Page.new)
    ServiceAreaV3.null_json_api(nil, NullJsonAPI.new(nil, area_data.to_json))
  end

  after do
    ServiceAreaV3.class_variable_set(:@@json_api, nil) if ServiceAreaV3.class_variable_defined?(:@@json_api)
  end

  it 'is taken for Spanish' do
    get '/es/servicios/chaos-control'

    expect(last_response.status).to eq(200)
    expect(last_response.body)
      .to include('hreflang="es" href="https://www.kleer.la/es/servicios/chaos-control"')
  end
end

# The two service routes answer under both segments and always passed the
# Spanish one, so the English pages declared /en/servicios/... as canonical —
# a URL that redirects back to the page declaring it.
describe 'canonical of an English service area' do
  def app
    Sinatra::Application.new
  end

  let(:area_data) do
    {
      'id' => 2,
      'slug' => 'team-agility',
      'name' => 'Team Agility',
      'lang' => 'en',
      'is_training_program' => false,
      'primary_color' => '#FF5733',
      'primary_font_color' => '#FFFFFF',
      'secondary_color' => '#33FF57',
      'secondary_font_color' => '#000000',
      'services' => []
    }
  end

  before do
    allow(Page).to receive(:load_from_keventer).and_return(Page.new)
    ServiceAreaV3.null_json_api(nil, NullJsonAPI.new(nil, area_data.to_json))
  end

  after do
    ServiceAreaV3.class_variable_set(:@@json_api, nil) if ServiceAreaV3.class_variable_defined?(:@@json_api)
  end

  it 'names the English segment' do
    get '/en/services/team-agility'

    expect(last_response.body)
      .to include('<link rel="canonical" href="https://www.kleer.la/en/services/team-agility"/>')
  end
end
