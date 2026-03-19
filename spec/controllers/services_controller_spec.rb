require 'spec_helper'
require './app'

describe '/servicios' do
  include Rack::Test::Methods

  def app
    Sinatra::Application.new
  end

  it 'responds successfully for Spanish route' do
    get '/servicios'
    expect(last_response).to be_ok
  end
  it 'responds successfully / at the end' do
    get '/servicios/'
    expect(last_response).to be_ok
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
            'faq' => [],
            'brochure' => '',
            'side_image' => '',
            'recommended' => []
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

    it 'returns 404 for non-existent service slug' do
      get '/es/servicios/cambio-organizacional/non-existent-service'
      expect(last_response.status).to eq(404)
    end
  end
end
