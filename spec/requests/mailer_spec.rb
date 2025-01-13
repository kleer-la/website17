require 'spec_helper'
require 'sinatra/flash'
require './app'
require './lib/services/mailer'

describe 'MyApp' do
  def app
    Sinatra::Application.new
  end

  describe 'POST /send-mail' do
    let(:mailer_instance) { instance_double(Mailer) }
    let(:api_url) { 'https://eventos.kleer.la/api/contact_us' }

    before do
      allow_any_instance_of(Sinatra::Application).to receive(:verify_recaptcha).and_return(true)
      allow(Mailer).to receive(:new).and_return(mailer_instance)
      allow(mailer_instance).to receive(:send).and_return(true)
      # Set session locale for consistent testing
      env 'rack.session', { locale: 'es' }
    end

    it 'should pass checkbox values to mailer when checked' do
      payload = {
        'name' => 'prueba',
        'email' => 'prueba@mail.com',
        'company' => 'Test Company',
        'can_we_contact' => 'on',
        'suscribe' => 'on',
        'context' => '/',
        'g-recaptcha-response' => 'valid-response'
      }

      expected_data = {
        name: 'prueba',
        email: 'prueba@mail.com',
        company: 'Test Company',
        context: '/',
        message: nil,
        resource_slug: nil,
        language: 'es',
        can_we_contact: true,
        suscribe: true
      }

      expect(Mailer).to receive(:new).with(api_url, expected_data)

      post '/send-mail', payload
    end

    it 'should handle unchecked checkboxes as false' do
      payload = {
        'name' => 'prueba',
        'email' => 'prueba@mail.com',
        'company' => 'Test Company',
        'context' => '/',
        'g-recaptcha-response' => 'valid-response'
      }

      expected_data = {
        name: 'prueba',
        email: 'prueba@mail.com',
        company: 'Test Company',
        context: '/',
        message: nil,
        resource_slug: nil,
        language: 'es',
        can_we_contact: false,
        suscribe: false
      }

      expect(Mailer).to receive(:new).with(api_url, expected_data)

      post '/send-mail', payload
    end

    it 'should return error with invalid captcha' do
      allow_any_instance_of(Sinatra::Application).to receive(:verify_recaptcha).and_return(false)

      payload = {
        'name' => 'prueba',
        'email' => 'prueba@mail.com',
        'company' => 'Test Company',
        'can_we_contact' => 'on',
        'suscribe' => 'on',
        'g-recaptcha-response' => 'invalid captcha response',
        'context' => '/'
      }
      post '/send-mail', payload
      expect(last_request.env['rack.session'][:flash][:error]).to match(/Ha ocurrido un error, su mensaje no fué enviado/)
    end
  end
end
