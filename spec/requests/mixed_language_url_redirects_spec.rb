require 'spec_helper'
require './app'

describe 'Mixed Language URL Redirects' do
  def app
    Sinatra::Application.new
  end

  describe 'redirects when language prefix and slug language mismatch' do
    context 'English prefix with Spanish slug' do
      it 'redirects /en/servicios to /en/services' do
        get '/en/servicios'

        expect(last_response.status).to eq(301)
        expect(last_response.location).to end_with('/en/services')
      end

      it 'redirects /en/recursos to /en/resources' do
        get '/en/recursos'

        expect(last_response.status).to eq(301)
        expect(last_response.location).to end_with('/en/resources')
      end

      it 'redirects /en/catalogo to /en/catalog' do
        get '/en/catalogo'

        expect(last_response.status).to eq(301)
        expect(last_response.location).to end_with('/en/catalog')
      end

      it 'redirects /en/formacion to /en/training' do
        get '/en/formacion'

        expect(last_response.status).to eq(301)
        expect(last_response.location).to end_with('/en/training')
      end

      it 'redirects /en/servicios/some-slug to /en/services/some-slug' do
        get '/en/servicios/coaching-agile'

        expect(last_response.status).to eq(301)
        expect(last_response.location).to end_with('/en/services/coaching-agile')
      end

      it 'redirects /en/recursos/some-slug to /en/resources/some-slug' do
        get '/en/recursos/scrum-guide'

        expect(last_response.status).to eq(301)
        expect(last_response.location).to end_with('/en/resources/scrum-guide')
      end

      it 'redirects /en/formacion/programas-capacitacion-empresarial to /en/training/programas-capacitacion-empresarial' do
        get '/en/formacion/programas-capacitacion-empresarial'

        expect(last_response.status).to eq(301)
        expect(last_response.location).to end_with('/en/training/programas-capacitacion-empresarial')
      end
    end

    context 'Spanish prefix with English slug' do
      it 'redirects /es/services to /es/servicios' do
        get '/es/services'

        expect(last_response.status).to eq(301)
        expect(last_response.location).to end_with('/es/servicios')
      end

      it 'redirects /es/resources to /es/recursos' do
        get '/es/resources'

        expect(last_response.status).to eq(301)
        expect(last_response.location).to end_with('/es/recursos')
      end

      it 'redirects /es/catalog to /es/catalogo' do
        get '/es/catalog'

        expect(last_response.status).to eq(301)
        expect(last_response.location).to end_with('/es/catalogo')
      end

      it 'redirects /es/services/some-slug to /es/servicios/some-slug' do
        get '/es/services/coaching-agile'

        expect(last_response.status).to eq(301)
        expect(last_response.location).to end_with('/es/servicios/coaching-agile')
      end

      it 'redirects /es/resources/some-slug to /es/recursos/some-slug' do
        get '/es/resources/scrum-guide'

        expect(last_response.status).to eq(301)
        expect(last_response.location).to end_with('/es/recursos/scrum-guide')
      end

      it 'redirects /es/training to /es/formacion' do
        get '/es/training'

        expect(last_response.status).to eq(301)
        expect(last_response.location).to end_with('/es/formacion')
      end

      it 'redirects /es/training/programas-capacitacion-empresarial to /es/formacion/programas-capacitacion-empresarial' do
        get '/es/training/programas-capacitacion-empresarial'

        expect(last_response.status).to eq(301)
        expect(last_response.location).to end_with('/es/formacion/programas-capacitacion-empresarial')
      end
    end

    # Note: We don't test "no redirect" cases (matching language prefix and slug)
    # because that's the default behavior. The important tests are above,
    # verifying that mixed language URLs DO redirect correctly.
  end
end
