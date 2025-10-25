require 'spec_helper'
require 'sinatra/flash'
require './app'
require './lib/services/mailer'

describe 'In-Company Quote Submission' do
  def app
    Sinatra::Application.new
  end

  describe 'POST /send-mail with incompany_quote form_type' do
    let(:mailer_instance) { instance_double(Mailer) }
    let(:mailer_url) { KeventerAPI.mailer_url }

    before do
      allow_any_instance_of(Sinatra::Application).to receive(:verify_recaptcha).and_return(true)
      allow(Mailer).to receive(:new).and_return(mailer_instance)
      allow(mailer_instance).to receive(:send).and_return(true)
    end

    context 'with online location' do
      it 'sends incompany quote email with online location' do
        env 'rack.session', { locale: 'es', flash: {} }

        payload = {
          'form_type' => 'incompany_quote',
          'name' => 'Juan Pérez',
          'email' => 'juan@example.com',
          'company' => 'Acme Corp',
          'location' => 'online',
          'when' => '2025-03',
          'attendees' => '15',
          'context' => '/es/cursos/123-test-course',
          'g-recaptcha-response' => 'valid-response'
        }

        expect(Mailer).to receive(:new).with(
          mailer_url,
          hash_including(
            name: 'Juan Pérez',
            email: 'juan@example.com',
            company: 'Acme Corp',
            language: 'es',
            resource_slug: '',
            can_we_contact: false,
            suscribe: false
          )
        ) do |url, data|
          expect(data[:message]).to include('Online')
          expect(data[:message]).to include('15')
          mailer_instance
        end

        post '/send-mail', payload

        expect(last_response.status).to eq(302)
        expect(last_request.env['rack.session'][:flash][:notice]).to eq('Su mensaje ha sido enviado correctamente')
      end
    end

    context 'with onsite location' do
      it 'sends incompany quote email with onsite location and place' do
        env 'rack.session', { locale: 'es', flash: {} }

        payload = {
          'form_type' => 'incompany_quote',
          'name' => 'María García',
          'email' => 'maria@example.com',
          'company' => 'Tech Solutions',
          'location' => 'presencial',
          'where' => 'Buenos Aires, Argentina',
          'when' => '2025-06',
          'attendees' => '20',
          'context' => '/es/cursos/456-another-course',
          'g-recaptcha-response' => 'valid-response'
        }

        expect(Mailer).to receive(:new).with(
          mailer_url,
          hash_including(
            name: 'María García',
            email: 'maria@example.com',
            company: 'Tech Solutions',
            language: 'es'
          )
        ) do |url, data|
          expect(data[:message]).to include('Presencial')
          expect(data[:message]).to include('Buenos Aires, Argentina')
          expect(data[:message]).to include('20')
          mailer_instance
        end

        post '/send-mail', payload

        expect(last_response.status).to eq(302)
        expect(last_request.env['rack.session'][:flash][:notice]).to eq('Su mensaje ha sido enviado correctamente')
      end
    end

    context 'with English locale' do
      it 'sends incompany quote email in English' do
        payload = {
          'form_type' => 'incompany_quote',
          'name' => 'John Doe',
          'email' => 'john@example.com',
          'company' => 'Global Inc',
          'location' => 'online',
          'when' => '2025-04',
          'attendees' => '12',
          'context' => '/en/courses/789-test-course',
          'g-recaptcha-response' => 'valid-response'
        }

        expect(Mailer).to receive(:new).with(
          mailer_url,
          hash_including(
            name: 'John Doe',
            email: 'john@example.com',
            company: 'Global Inc',
            language: 'en'
          )
        ) do |url, data|
          expect(data[:message]).to include('Online')
          expect(data[:message]).to include('12')
          mailer_instance
        end

        env 'rack.session', { locale: 'en', flash: {} }
        post '/en/send-mail', payload

        expect(last_response.status).to eq(302)
        expect(last_request.env['rack.session'][:flash][:notice]).to eq('Your message has been sent successfully')
      end
    end

    context 'with minimum attendees' do
      it 'accepts exactly 8 attendees' do
        env 'rack.session', { locale: 'es', flash: {} }

        payload = {
          'form_type' => 'incompany_quote',
          'name' => 'Test User',
          'email' => 'test@example.com',
          'company' => 'Test Co',
          'location' => 'online',
          'when' => '2025-05',
          'attendees' => '8',
          'context' => '/es/cursos/123-test',
          'g-recaptcha-response' => 'valid-response'
        }

        expect(Mailer).to receive(:new).with(
          mailer_url,
          hash_including(name: 'Test User')
        ) do |url, data|
          expect(data[:message]).to include('8')
          mailer_instance
        end

        post '/send-mail', payload

        expect(last_response.status).to eq(302)
      end
    end

    context 'with invalid recaptcha' do
      it 'returns error with invalid captcha' do
        allow_any_instance_of(Sinatra::Application).to receive(:verify_recaptcha).and_return(false)
        env 'rack.session', { locale: 'es', flash: {} }

        payload = {
          'form_type' => 'incompany_quote',
          'name' => 'Test User',
          'email' => 'test@example.com',
          'company' => 'Test Co',
          'location' => 'online',
          'when' => '2025-05',
          'attendees' => '10',
          'context' => '/es/cursos/123-test',
          'g-recaptcha-response' => 'invalid-response'
        }

        post '/send-mail', payload

        expect(last_response.status).to eq(302)
        expect(last_request.env['rack.session'][:flash][:error]).to match(/Ha ocurrido un error/)
      end
    end
  end
end
