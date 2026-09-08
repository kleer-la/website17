require 'spec_helper'
require './app'

# An area lives in one section — /servicios or /formacion — and which one is a
# flag on the record, not a property of the URL. When an area moved between
# them the old URL answered 404: the page died and so did whatever linked to
# it. Four training areas were 404ing under /servicios and two service areas
# under /formacion.
#
# The redirect is derived from the flag rather than written down as a pair, so
# flipping `is_training_program` in the admin moves the offer and turns the
# redirect around at the same time. Nothing is left behind to go stale, and
# changing our mind later costs a checkbox.
describe 'an area asked for in the wrong section' do
  def app
    Sinatra::Application.new
  end

  def area(slug:, training:, lang: 'es')
    { 'id' => 1, 'slug' => slug, 'name' => 'Un área', 'lang' => lang,
      'is_training_program' => training, 'primary_color' => '#FF5733',
      'primary_font_color' => '#FFFFFF', 'secondary_color' => '#33FF57',
      'secondary_font_color' => '#000000', 'services' => [] }
  end

  def serving(data)
    ServiceAreaV3.null_json_api(nil, NullJsonAPI.new(nil, data.to_json))
  end

  before { allow(Page).to receive(:load_from_keventer).and_return(Page.new) }

  after do
    ServiceAreaV3.class_variable_set(:@@json_api, nil) if ServiceAreaV3.class_variable_defined?(:@@json_api)
  end

  context 'a training programme asked for under /servicios' do
    before { serving(area(slug: 'adopcion-ia-empresas', training: true)) }

    it 'sends it to /formacion instead of 404ing' do
      get '/es/servicios/adopcion-ia-empresas'

      expect(last_response.status).to eq 301
      expect(last_response.headers['Location']).to end_with '/es/formacion/adopcion-ia-empresas'
    end

    it 'still answers under its own section' do
      get '/es/formacion/adopcion-ia-empresas'

      expect(last_response.status).to eq 200
    end
  end

  context 'a service area asked for under /formacion' do
    before { serving(area(slug: 'agilidad-equipos', training: false)) }

    it 'sends it to /servicios instead of 404ing' do
      get '/es/formacion/agilidad-equipos'

      expect(last_response.status).to eq 301
      expect(last_response.headers['Location']).to end_with '/es/servicios/agilidad-equipos'
    end

    it 'still answers under its own section' do
      get '/es/servicios/agilidad-equipos'

      expect(last_response.status).to eq 200
    end
  end

  context 'in English, where the sections are named differently' do
    it 'sends a training programme from /services to /training' do
      serving(area(slug: 'ai-adoption', training: true, lang: 'en'))

      get '/en/services/ai-adoption'

      expect(last_response.status).to eq 301
      expect(last_response.headers['Location']).to end_with '/en/training/ai-adoption'
    end

    it 'sends a service area from /training to /services' do
      serving(area(slug: 'team-agility', training: false, lang: 'en'))

      get '/en/training/team-agility'

      expect(last_response.status).to eq 301
      expect(last_response.headers['Location']).to end_with '/en/services/team-agility'
    end
  end

  # A sub-service resolves to the area that holds it, so the record's own slug
  # is the parent's. Redirecting to that slug threw away which sub-service was
  # asked for — /servicios/gestion-producto landed on the programmes area
  # instead of on the page for gestión de producto.
  context 'a slug that resolves to the area holding it' do
    before { serving(area(slug: 'programas-capacitacion-empresarial', training: true)) }

    it 'keeps the slug that was asked for' do
      get '/es/servicios/gestion-producto'

      expect(last_response.status).to eq 301
      expect(last_response.headers['Location']).to end_with '/es/formacion/gestion-producto'
    end
  end

  it 'still 404s when there is no such area' do
    ServiceAreaV3.null_json_api(nil, NullJsonAPI.new(nil, 'null'))

    get '/es/servicios/no-existe'

    expect(last_response.status).to eq 404
  end
end
