require 'spec_helper'
require './app'

# The hero links each service of an area to <area>/<service>. That page exists
# under /servicios, and only there: the two-segment route passes when the area
# is a training programme, so under /formacion every one of those links is a
# 404 the visitor walks into from the body of a commercial page.
describe 'the service links of an area' do
  def app
    Sinatra::Application.new
  end

  let(:services) do
    [
      { 'id' => 10, 'slug' => 'gestion-producto', 'name' => 'Gestión de Producto' },
      { 'id' => 11, 'slug' => 'desarrollo-liderazgo-agil', 'name' => 'Liderazgo' }
    ]
  end

  let(:area_data) do
    {
      'id' => 1,
      'slug' => 'programas-capacitacion-empresarial',
      'name' => 'Programas de Capacitación',
      'lang' => 'es',
      'is_training_program' => training,
      'primary_color' => '#FF5733',
      'primary_font_color' => '#FFFFFF',
      'secondary_color' => '#33FF57',
      'secondary_font_color' => '#000000',
      'services' => services
    }
  end

  before do
    allow(Page).to receive(:load_from_keventer).and_return(Page.new)
    ServiceAreaV3.null_json_api(nil, NullJsonAPI.new(nil, area_data.to_json))
  end

  after do
    ServiceAreaV3.class_variable_set(:@@json_api, nil) if ServiceAreaV3.class_variable_defined?(:@@json_api)
  end

  context 'when the area is a training programme' do
    let(:training) { true }

    it 'links each service to the area it has of its own' do
      get '/es/formacion/programas-capacitacion-empresarial'

      expect(last_response.body).to include('href="/es/formacion/gestion-producto"')
      expect(last_response.body).not_to include('/es/formacion/programas-capacitacion-empresarial/')
    end
  end

  context 'when the area is a service area' do
    let(:training) { false }

    it 'still links each service to its page' do
      get '/es/servicios/programas-capacitacion-empresarial'

      expect(last_response.body)
        .to include('href="/es/servicios/programas-capacitacion-empresarial/gestion-producto"')
    end
  end
end
