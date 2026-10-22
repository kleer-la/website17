require 'spec_helper'
require './app'

describe 'Training Routes' do
  def app
    Sinatra::Application.new
  end

  describe 'GET /training/:slug' do
    context 'when service area has no content in the requested language' do
      let(:spanish_only_service_area_data) do
        {
          'id' => 1,
          'slug' => 'programas-capacitacion-empresarial',
          'name' => 'Programas de Capacitación Empresarial',
          'lang' => 'es',  # Content is only available in Spanish
          'is_training_program' => true,
          'services' => []
        }
      end

      let(:null_api) { NullJsonAPI.new(nil, spanish_only_service_area_data.to_json) }

      before do
        ServiceAreaV3.null_json_api(nil, null_api)
      end

      after do
        ServiceAreaV3.class_variable_set(:@@json_api, nil) if ServiceAreaV3.class_variable_defined?(:@@json_api)
      end

      it 'redirects to /en/catalog when accessing /en/training/:slug with Spanish-only content' do
        get '/en/training/programas-capacitacion-empresarial'

        expect(last_response.status).to eq(301)
        expect(last_response.location).to end_with('/en/catalog')
      end
    end

    context 'when service area is English but accessed via Spanish URL' do
      let(:english_only_service_area_data) do
        {
          'id' => 1,
          'slug' => 'corporate-training-programs',
          'name' => 'Corporate Training Programs',
          'lang' => 'en',  # Content is only available in English
          'is_training_program' => true,
          'services' => []
        }
      end

      let(:null_api) { NullJsonAPI.new(nil, english_only_service_area_data.to_json) }

      before do
        ServiceAreaV3.null_json_api(nil, null_api)
      end

      after do
        ServiceAreaV3.class_variable_set(:@@json_api, nil) if ServiceAreaV3.class_variable_defined?(:@@json_api)
      end

      it 'redirects to /es/catalogo when accessing /es/formacion/:slug with English-only content' do
        get '/es/formacion/corporate-training-programs'

        expect(last_response.status).to eq(301)
        expect(last_response.location).to end_with('/es/catalogo')
      end
    end

    context 'when service area has content in the requested language' do
      let(:service_area_data) do
        {
          'id' => 1,
          'slug' => 'programas-capacitacion-empresarial',
          'name' => 'Corporate Training Programs',
          'lang' => 'en',  # Content is available in English
          'is_training_program' => true,
          'primary_color' => '#FF5733',
          'primary_font_color' => '#FFFFFF',
          'secondary_color' => '#33FF57',
          'secondary_font_color' => '#000000',
          'services' => []
        }
      end

      let(:null_api) { NullJsonAPI.new(nil, service_area_data.to_json) }

      before do
        ServiceAreaV3.null_json_api(nil, null_api)
      end

      after do
        ServiceAreaV3.class_variable_set(:@@json_api, nil) if ServiceAreaV3.class_variable_defined?(:@@json_api)
      end

      it 'renders the service area page when content exists in the requested language' do
        get '/en/training/programas-capacitacion-empresarial'

        expect(last_response.status).to eq(200)
      end
    end
  end

  # A programme's service has no page of its own: /formacion/<service slug> loads
  # the area. Keventer resolves the slug of a service that is not published to
  # that area too, so the answer has to come from the services it lists (#458).
  describe 'a service slug under a training area' do
    let(:area_data) do
      { 'id' => 1, 'slug' => 'programa', 'name' => 'Programa', 'lang' => 'es', 'is_training_program' => true,
        'primary_color' => '#FF5733', 'primary_font_color' => '#FFFFFF',
        'secondary_color' => '#33FF57', 'secondary_font_color' => '#000000',
        'services' => [{ 'id' => 5, 'slug' => 'servicio-vigente', 'name' => 'Vigente' }],
        'service_redirects' => {} }
    end

    before { ServiceAreaV3.null_json_api(nil, NullJsonAPI.new(nil, area_data.to_json)) }

    after do
      ServiceAreaV3.class_variable_set(:@@json_api, nil) if ServiceAreaV3.class_variable_defined?(:@@json_api)
    end

    { '/es/formacion' => 'es', '/en/training' => 'en' }.each do |base, lang|
      it "answers 404 under #{base} for a service that is not listed" do
        ServiceAreaV3.null_json_api(nil, NullJsonAPI.new(nil, area_data.merge('lang' => lang).to_json))

        get "#{base}/servicio-retirado"

        expect(last_response.status).to eq(404)
      end
    end

    it 'sends a service that left with a redirect to where it went' do
      area_data['service_redirects'] = { 'servicio-retirado' => '/es/formacion/otro' }
      ServiceAreaV3.null_json_api(nil, NullJsonAPI.new(nil, area_data.to_json))

      get '/es/formacion/servicio-retirado'

      expect(last_response.status).to eq(301)
      expect(last_response.location).to end_with('/es/formacion/otro')
    end

    it 'still renders the area for the slug of a listed service' do
      get '/es/formacion/servicio-vigente'

      expect(last_response.status).to eq(200)
    end

    it 'still renders the area under its own slug' do
      get '/es/formacion/programa'

      expect(last_response.status).to eq(200)
    end
  end
end
