require 'spec_helper'
require './app'

describe '/servicios' do
  include Rack::Test::Methods

  def app
    Sinatra::Application.new
  end

  it 'responds successfully for Spanish route' do
    get '/es/servicios'
    expect(last_response).to be_ok
  end
  it 'responds successfully / at the end' do
    get '/es/servicios/'
    expect(last_response).to be_ok
  end

  # The section names its language, so it answers under its prefix and sends
  # the bare form there instead of serving it a second time.
  it 'sends the unprefixed form to the Spanish prefix' do
    get '/servicios'

    expect(last_response.status).to eq(301)
    expect(last_response.location).to end_with('/es/servicios')
  end

  # An area can be an offering in itself: it carries the blocks a service has,
  # and its page presents them with the same contact CTA a service page has.
  describe 'GET /servicios/:area_slug when the area is an offering' do
    let(:offering_area_data) do
      {
        'id' => 4,
        'slug' => 'adopcion-ia',
        'name' => 'Adopción de IA',
        'lang' => 'es',
        'is_training_program' => false,
        'primary_color' => '#4dd3e8',
        'primary_font_color' => '#FFFFFF',
        'secondary_color' => '#34e3ff',
        'secondary_font_color' => '#000000',
        'icon' => '/app/img/icons/ev-org.svg',
        'summary' => 'Summary text',
        'cta_message' => 'CTA message',
        'slogan' => 'Slogan',
        'subtitle' => 'Subtitle',
        'description' => 'Description',
        'target' => 'Target audience',
        'value_proposition' => 'Value proposition',
        'seo_title' => 'SEO Title',
        'seo_description' => 'Adopción de IA para empresas',
        'outcomes' => ['Equipos que usan IA a diario', 'Menos retrabajo'],
        'definitions' => nil,
        'program' => [['Diagnóstico inicial', 'Dos semanas de relevamiento'], ['Pilotos', 'Tres equipos']],
        'pricing' => 'Desde USD 5.000 mensuales',
        'faq' => [['¿Cuánto dura el acompañamiento?', 'Entre tres y seis meses']],
        'brochure' => 'https://cdn.example.com/adopcion-ia.pdf',
        'recommended' => [
          { 'type' => 'article', 'title' => 'Lectura recomendada', 'subtitle' => 'Sub', 'slug' => 'lectura',
            'cover' => '', 'lang' => 'es', 'relevance_order' => 1, 'level' => 'initial' }
        ],
        'services' => [],
        'testimonies' => []
      }
    end

    before do
      ServiceAreaV3.null_json_api(nil, NullJsonAPI.new(nil, offering_area_data.to_json))
    end

    after do
      ServiceAreaV3.class_variable_set(:@@json_api, nil) if ServiceAreaV3.class_variable_defined?(:@@json_api)
    end

    it 'presents the outcomes, program, FAQ and brochure like a service page does' do
      get '/es/servicios/adopcion-ia'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('Equipos que usan IA a diario')
      expect(last_response.body).to include('Diagnóstico inicial')
      expect(last_response.body).to include('Dos semanas de relevamiento')
      expect(last_response.body).to include('¿Cuánto dura el acompañamiento?')
      expect(last_response.body).to include('Entre tres y seis meses')
      expect(last_response.body).to include('https://cdn.example.com/adopcion-ia.pdf')
    end

    # The price is negotiated, not listed: it stays in the CMS for the team.
    it 'does not show the pricing' do
      get '/es/servicios/adopcion-ia'

      expect(last_response.body).not_to include('Desde USD 5.000 mensuales')
    end

    it 'shows what the area recommends' do
      get '/es/servicios/adopcion-ia'

      expect(last_response.body).to include('Lectura recomendada')
    end

    it 'describes the area as a Service for search engines' do
      get '/es/servicios/adopcion-ia'

      expect(last_response.body).to include('"@type":"Service"')
      expect(last_response.body).to include('Adopción de IA para empresas')
    end

    it 'does not show an empty services section when the area has no services' do
      get '/es/servicios/adopcion-ia'

      expect(last_response.body).not_to include('CTA message')
    end
  end

  describe 'GET /servicios/:area_slug/:service_slug' do
    let(:service_area_data) do
      {
        'id' => 3,
        'slug' => 'cambio-organizacional',
        'name' => 'Cambio Organizacional',
        'lang' => 'es',
        'is_training_program' => false,
        'primary_color' => '#4dd3e8',
        'primary_font_color' => '#FFFFFF',
        'secondary_color' => '#34e3ff',
        'secondary_font_color' => '#000000',
        'icon' => '/app/img/icons/ev-org.svg',
        'summary' => 'Summary text',
        'cta_message' => 'CTA message',
        'slogan' => 'Slogan',
        'subtitle' => 'Subtitle',
        'description' => 'Description',
        'target' => 'Target audience',
        'value_proposition' => 'Value proposition',
        'seo_title' => 'SEO Title',
        'seo_description' => 'SEO Description',
        'services' => [
          {
            'id' => 6,
            'slug' => 'diseno-organizacional',
            'name' => 'Diseño Organizacional',
            'subtitle' => 'Rediseña tu organización',
            'value_proposition' => '<p>Value proposition</p>',
            'outcomes' => ['Outcome 1', 'Outcome 2'],
            'definitions' => nil,
            'program' => [['Module 1', 'Detail 1']],
            'target' => '<p>Target</p>',
            'pricing' => '',
            'faq' => [['¿Se puede hacer remoto?', 'Sí, todo el proceso']],
            'brochure' => '',
            'side_image' => '',
            'recommended' => [],
            'recommended_way_title' => 'La Membresía IA',
            'recommended_way_note' => 'Funciona para el 80% de las empresas',
            'recommended_way_summary' => '<ol><li><strong>Diagnóstico</strong> — 2 semanas</li></ol>',
            'recommended_way_details' => '<h3>Detalles completos</h3><p>Roles, timing y entregables...</p>'
          }
        ],
        'testimonies' => []
      }
    end

    let(:null_api) { NullJsonAPI.new(nil, service_area_data.to_json) }

    before do
      ServiceAreaV3.null_json_api(nil, null_api)
    end

    after do
      ServiceAreaV3.class_variable_set(:@@json_api, nil) if ServiceAreaV3.class_variable_defined?(:@@json_api)
    end

    it 'renders the service landing page' do
      get '/es/servicios/cambio-organizacional/diseno-organizacional'
      expect(last_response.status).to eq(200)
    end

    it 'includes forma recomendada when present on the service' do
      get '/es/servicios/cambio-organizacional/diseno-organizacional'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('La Membresía IA')
      expect(last_response.body).to include('Funciona para el 80%')
      expect(last_response.body).to include('Detalles completos')
    end

    it 'renders the FAQ as an accordion' do
      get '/es/servicios/cambio-organizacional/diseno-organizacional'

      expect(last_response.body).to include('Preguntas frecuentes')
      expect(last_response.body).to include('¿Se puede hacer remoto?')
      expect(last_response.body).to include('Sí, todo el proceso')
    end

    it 'returns 404 for non-existent service slug' do
      get '/es/servicios/cambio-organizacional/non-existent-service'
      expect(last_response.status).to eq(404)
    end

    # A service moved to another area keeps its slug; its old URL follows it.
    context 'when the service moved to another area' do
      let(:training_area) do
        ServiceAreaV3.new.load_from_json(
          service_area_data.merge(
            'slug' => 'programas-capacitacion-empresarial', 'is_training_program' => true,
            'services' => [service_area_data['services'][0].merge('slug' => 'programa-producto')]
          )
        )
      end

      it 'sends the old URL to the training programme that now holds it' do
        allow(ServiceAreaV3).to receive(:create_keventer).and_call_original
        allow(ServiceAreaV3).to receive(:create_keventer).with('programa-producto').and_return(training_area)

        get '/es/servicios/cambio-organizacional/programa-producto'

        expect(last_response.status).to eq(301)
        expect(last_response.location).to end_with('/es/formacion/programa-producto')
      end
    end

    # The restyled pages sit behind a flag, so QA can show them while
    # production keeps serving the current ones.
    context 'with the services_redesign flag' do
      after { Toggle.turn(:services_redesign, false) }

      it 'keeps the current area page while the flag is off' do
        get '/es/servicios/cambio-organizacional'

        expect(last_response.status).to eq(200)
        expect(last_response.body).not_to include('services-v2.css')
        expect(last_response.body).to include('area-hero-full')
      end

      it 'serves the restyled area page when the flag is on' do
        Toggle.turn(:services_redesign, true)

        get '/es/servicios/cambio-organizacional'

        expect(last_response.status).to eq(200)
        expect(last_response.body).to include('services-v2.css')
        expect(last_response.body).not_to include('area-hero-full')
        expect(last_response.body).to include('Diseño Organizacional')
      end

      it 'shows a service card authored in the CMS as a card of the grid' do
        service_area_data['services'][0]['card_description'] = '<h2 class="rw-details-title">Frente 01</h2>'
        ServiceAreaV3.null_json_api(nil, NullJsonAPI.new(nil, service_area_data.to_json))
        Toggle.turn(:services_redesign, true)

        get '/es/servicios/cambio-organizacional'

        card = '<article class="svc2-card"><h2 class="rw-details-title">Frente 01</h2></article>'
        expect(last_response.body).to include(card)
      end

      it 'serves the restyled service page when the flag is on' do
        Toggle.turn(:services_redesign, true)

        get '/es/servicios/cambio-organizacional/diseno-organizacional'

        expect(last_response.status).to eq(200)
        expect(last_response.body).to include('services-v2.css')
        expect(last_response.body).to include('La Membresía IA')
        expect(last_response.body).to include('Detalles completos')
        expect(last_response.body).to include('¿Se puede hacer remoto?')
      end
    end
  end
end
