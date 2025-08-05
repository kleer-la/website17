require 'spec_helper'
require './app'

describe 'Certificates routes' do
  include Rack::Test::Methods

  def app
    Sinatra::Application.new
  end

  before do
    # Mock minimal required dependencies
    allow_any_instance_of(Sinatra::Application).to receive(:@meta_tags).and_return(double.as_null_object)
  end

  describe 'Certificate validation pages' do
    context 'Spanish language' do
      before do
        env 'rack.session', { locale: 'es' }
      end

      describe 'GET /es/certificado (processed as /certificado)' do
        it 'renders the certificate form page' do
          get '/es/certificado'
          expect(last_response.status).to eq(200)
          expect(last_response.body).to include('Certificados')
        end

        it 'passes search term parameter to the form' do
          get '/es/certificado?q=test123'
          expect(last_response.status).to eq(200)
          expect(last_response.body).to include('test123')
        end
      end

      describe 'POST /es/certificado (processed as /certificado)' do
        let(:mock_certificate_service) { double('FileStoreService') }

        before do
          allow(FileStoreService).to receive(:create_s3).and_return(mock_certificate_service)
        end

        context 'when certificate is found' do
          before do
            allow(mock_certificate_service).to receive(:find_certificate).with('valid_code').and_return('certificate_url.pdf')
          end

          it 'renders the certificate page' do
            post '/es/certificado', q: 'valid_code'
            expect(last_response.status).to eq(200)
            expect(last_response.body).to include('certificate_url.pdf')
          end
        end

        context 'when certificate is not found' do
          before do
            allow(mock_certificate_service).to receive(:find_certificate).with('invalid_code').and_return(nil)
          end

          it 'shows error message and renders form again' do
            post '/es/certificado', q: 'invalid_code'
            expect(last_response.status).to eq(200)
            expect(last_response.body).to include('No encontramos un certificado con ese código')
          end
        end
      end
    end

    context 'English language' do
      before do
        env 'rack.session', { locale: 'en' }
      end

      describe 'GET /en/certificate (processed as /certificate)' do
        it 'renders the certificate form page in English' do
          get '/en/certificate'
          expect(last_response.status).to eq(200)
          expect(last_response.body).to include('Certificates')
        end

        it 'passes search term parameter to the form' do
          get '/en/certificate?q=test456'
          expect(last_response.status).to eq(200)
          expect(last_response.body).to include('test456')
        end
      end

      describe 'POST /en/certificate (processed as /certificate)' do
        let(:mock_certificate_service) { double('FileStoreService') }

        before do
          allow(FileStoreService).to receive(:create_s3).and_return(mock_certificate_service)
        end

        context 'when certificate is found' do
          before do
            allow(mock_certificate_service).to receive(:find_certificate).with('valid_code').and_return('certificate_url.pdf')
          end

          it 'renders the certificate page' do
            post '/en/certificate', q: 'valid_code'
            expect(last_response.status).to eq(200)
            expect(last_response.body).to include('certificate_url.pdf')
          end
        end

        context 'when certificate is not found' do
          before do
            allow(mock_certificate_service).to receive(:find_certificate).with('invalid_code').and_return(nil)
          end

          it 'shows error message in English and renders form again' do
            post '/en/certificate', q: 'invalid_code'
            expect(last_response.status).to eq(200)
            expect(last_response.body).to include('We couldn\'t find a certificate with that code')
          end
        end
      end
    end

    context 'Direct route access (bypassing language middleware)' do
      before do
        env 'rack.session', { locale: 'es' }
      end

      describe 'GET /certificado' do
        it 'renders the certificate form page directly' do
          get '/certificado'
          expect(last_response.status).to eq(200)
          expect(last_response.body).to include('Certificados')
        end
      end

      describe 'GET /certificate' do
        it 'renders the certificate form page directly' do
          get '/certificate'
          expect(last_response.status).to eq(200)
          # The page renders the certificate form (language depends on session locale)
          expect(last_response.body).to match(/Certificados|Certificates/)
        end
      end

      describe 'POST /certificado' do
        let(:mock_certificate_service) { double('FileStoreService') }

        before do
          allow(FileStoreService).to receive(:create_s3).and_return(mock_certificate_service)
          allow(mock_certificate_service).to receive(:find_certificate).with('test_code').and_return(nil)
        end

        it 'works with direct route access' do
          post '/certificado', q: 'test_code'
          expect(last_response.status).to eq(200)
        end
      end
    end
  end

  describe 'Menu integration' do
    it 'includes certificate validation in Spanish Cursos menu' do
      # Load Spanish navbar configuration
      require 'yaml'
      es_data = YAML.load_file('locales/es.yml')
      cursos_menu = es_data['es']['navbar'].find { |item| item['text'] == 'Cursos' }
      
      expect(cursos_menu).not_to be_nil
      expect(cursos_menu['options']).not_to be_nil
      
      validate_cert_option = cursos_menu['options'].find { |opt| opt['text'] == 'Validar certificado' }
      expect(validate_cert_option).not_to be_nil
      expect(validate_cert_option['url']).to eq('/certificado')
      expect(validate_cert_option['inside']).to be true
    end

    it 'includes certificate validation in English Courses menu' do
      # Load English navbar configuration
      require 'yaml'
      en_data = YAML.load_file('locales/en.yml')
      courses_menu = en_data['en']['navbar'].find { |item| item['text'] == 'Courses' }
      
      expect(courses_menu).not_to be_nil
      expect(courses_menu['options']).not_to be_nil
      
      validate_cert_option = courses_menu['options'].find { |opt| opt['text'] == 'Validate Certificate' }
      expect(validate_cert_option).not_to be_nil
      expect(validate_cert_option['url']).to eq('/certificate')
      expect(validate_cert_option['inside']).to be true
    end
  end

  describe 'Internationalization' do
    it 'has proper Spanish translations for certificate errors' do
      require 'i18n'
      I18n.load_path = Dir['locales/*.yml']
      I18n.backend.load_translations
      I18n.locale = :es
      
      expect(I18n.t('certificates.not_found')).to eq('No encontramos un certificado con ese código')
      expect(I18n.t('certificate-form.title')).to eq('Certificados')
      expect(I18n.t('certificate-form.submit.text')).to eq('Obten tu certificado')
    end

    it 'has proper English translations for certificate errors' do
      require 'i18n'
      I18n.load_path = Dir['locales/*.yml']
      I18n.backend.load_translations
      I18n.locale = :en
      
      expect(I18n.t('certificates.not_found')).to eq('We couldn\'t find a certificate with that code')
      expect(I18n.t('certificate-form.title')).to eq('Certificates')
      expect(I18n.t('certificate-form.submit.text')).to eq('Get certificate')
    end
  end
end