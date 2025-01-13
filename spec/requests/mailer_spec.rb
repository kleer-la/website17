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
    let(:contacts_url) { KeventerAPI.contacts_url }

    before do
      allow_any_instance_of(Sinatra::Application).to receive(:verify_recaptcha).and_return(true)
      allow(Mailer).to receive(:new).and_return(mailer_instance)
      allow(mailer_instance).to receive(:send).and_return(true)
      env 'rack.session', { locale: 'es' }
    end

    it 'should send multiple emails when additional resources are selected' do
      payload = {
        'name' => 'prueba',
        'email' => 'prueba@mail.com',
        'company' => 'Test Company',
        'can_we_contact' => 'on',
        'suscribe' => 'on',
        'context' => '/',
        'resource_slug' => 'main-resource',
        'ad-resource1' => 'on',
        'ad-resource2' => 'on',
        'g-recaptcha-response' => 'valid-response'
      }

      base_data = {
        name: 'prueba',
        email: 'prueba@mail.com',
        company: 'Test Company',
        context: '/',
        message: nil,
        language: 'es',
        can_we_contact: true,
        suscribe: true
      }

      # Setup session
      env 'rack.session', { locale: 'es', flash: {} }

      # Expect main resource email
      expect(Mailer).to receive(:new).with(
        contacts_url,
        hash_including(base_data.merge(resource_slug: 'main-resource'))
      ).ordered

      # Expect additional resource emails
      expect(Mailer).to receive(:new).with(
        contacts_url,
        hash_including(base_data.merge(resource_slug: 'resource1'))
      ).ordered

      expect(Mailer).to receive(:new).with(
        contacts_url,
        hash_including(base_data.merge(resource_slug: 'resource2'))
      ).ordered

      post '/send-mail', payload

      expect(last_response.status).to eq(302)
      expect(last_request.env['rack.session'][:flash][:notice]).to eq('Su mensaje ha sido enviado correctamente')
    end

    it 'should only send one email when no additional resources selected' do
      payload = {
        'name' => 'prueba',
        'email' => 'prueba@mail.com',
        'company' => 'Test Company',
        'can_we_contact' => 'on',
        'suscribe' => 'on',
        'context' => '/',
        'resource_slug' => 'main-resource',
        'g-recaptcha-response' => 'valid-response'
      }

      # Setup session
      env 'rack.session', { locale: 'es', flash: {} }

      expected_data = {
        name: 'prueba',
        email: 'prueba@mail.com',
        company: 'Test Company',
        context: '/',
        message: nil,
        resource_slug: 'main-resource',
        language: 'es',
        can_we_contact: true,
        suscribe: true
      }

      expect(Mailer).to receive(:new).once.with(contacts_url, expected_data)

      post '/send-mail', payload

      expect(last_response.status).to eq(302)
      expect(last_request.env['rack.session'][:flash][:notice]).to eq('Su mensaje ha sido enviado correctamente')
    end

    it 'should return error with invalid captcha' do
      allow_any_instance_of(Sinatra::Application).to receive(:verify_recaptcha).and_return(false)

      # Setup session
      env 'rack.session', { locale: 'es', flash: {} }

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

      expect(last_response.status).to eq(302)
      expect(last_request.env['rack.session'][:flash][:error]).to match(/Ha ocurrido un error, su mensaje no fué enviado/)
    end
  end
end
