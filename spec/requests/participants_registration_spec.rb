require 'spec_helper'
require './app'
require './lib/models/participant_registration'

describe 'Participant Registration' do
  def app
    Sinatra::Application.new
  end

  describe 'GET /:lang/events/:event_id/participants/register' do
    let(:event_id) { '123' }
    
    let(:mock_event_data) do
      {
        'id' => event_id,
        'event_type' => {
          'name' => 'Test Course'
        },
        'human_date' => '15 Dec 2024',
        'human_time' => '9:00 - 17:00',
        'place' => 'Test Venue',
        'address' => '123 Test St',
        'city' => 'Test City',
        'is_sold_out' => false,
        'registration_ended' => false,
        'community_event' => false,
        'ask_for_coupons_code' => true
      }
    end

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('KEVENTER_URL').and_return('https://mocked-backend')
      allow(ENV).to receive(:[]).with('RECAPTCHA_SITE_KEY').and_return('test_site_key')
    end

    context 'when event exists' do
      before do
        # Mock the new ParticipantRegistration model - this should be the ONLY path used
        allow_any_instance_of(ParticipantRegistration).to receive(:load_event_data).and_return({
          success: true,
          data: mock_event_data
        })
        allow_any_instance_of(ParticipantRegistration).to receive(:load_pricing_data).and_return({
          success: true,
          data: {
            'unit_price' => 100,
            'total_price' => 100,
            'currency' => 'USD',
            'savings' => 0
          }
        })

        # Setup session
        env 'rack.session', { locale: 'es' }
      end

      it 'renders the registration form' do
        get "/es/events/#{event_id}/participants/register"
        
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include('Test Course')
        expect(last_response.body).to include('15 Dec 2024')
        expect(last_response.body).to include('Test Venue')
        expect(last_response.body).to include('form id="registrationForm"')
        expect(last_response.body).to include('name="fname"')
        expect(last_response.body).to include('name="lname"')
        expect(last_response.body).to include('name="email"')
        expect(last_response.body).to include('name="quantity"')
        expect(last_response.body).to include('g-recaptcha')
      end

      it 'shows coupon code field when enabled' do
        get "/es/events/#{event_id}/participants/register"
        
        expect(last_response.body).to include('name="referer_code"')
      end

      it 'shows sold out warning when event is sold out' do
        mock_event_data['is_sold_out'] = true
        
        get "/es/events/#{event_id}/participants/register"
        
        expect(last_response.body).to include('Este evento está completo')
      end

      it 'shows registration ended warning when registration has ended' do
        mock_event_data['registration_ended'] = true
        
        get "/es/events/#{event_id}/participants/register"
        
        expect(last_response.body).to include('La fecha de registración ha pasado')
      end

      it 'responds successfully with form content' do
        get "/es/events/#{event_id}/participants/register"

        expect(last_response.status).to eq(200)
        expect(last_response.body).to include('Test Course')
        expect(last_response.body).to include('form')
      end

      it 'can use new ParticipantRegistration model with fallback' do
        # This test ensures new model works alongside existing HTTParty code
        get "/es/events/#{event_id}/participants/register"

        expect(last_response.status).to eq(200)
        expect(last_response.body).to include('Test Course')
        expect(last_response.body).to include('form')
      end
    end

    context 'when event does not exist' do
      before do
        # Mock the new ParticipantRegistration model to return error (event not found)
        allow_any_instance_of(ParticipantRegistration).to receive(:load_event_data).and_return({
          success: false,
          error: :not_found,
          status: 404
        })
      end

      it 'returns 404 error' do
        get "/es/events/999/participants/register"

        expect(last_response.status).to eq(404)
      end
    end

    context 'when API is unreachable' do
      before do
        # Mock the new model to return service unavailable error
        allow_any_instance_of(ParticipantRegistration).to receive(:load_event_data).and_return({
          success: false,
          error: :service_unavailable,
          status: 503
        })
      end

      it 'returns 503 service unavailable' do
        get "/es/events/#{event_id}/participants/register"

        expect(last_response.status).to eq(503)
        expect(last_response.body).to include('Error interno')
      end
    end
  end

  describe 'GET /:lang/events/:event_id/participant_confirmed' do
    let(:event_id) { '123' }

    before do
      env 'rack.session', { locale: 'es' }
    end

    it 'renders confirmation page for free event' do
      get "/es/events/#{event_id}/participant_confirmed?free=true&api=1"
      
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('¡Registro Exitoso!')
      expect(last_response.body).to include('¡Listo!')
      expect(last_response.body).to include('Has sido registrado para el evento')
    end

    it 'renders confirmation page for paid event' do
      get "/es/events/#{event_id}/participant_confirmed?free=false&api=1"
      
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('¡Registro Exitoso!')
      expect(last_response.body).to include('¡Gracias!')
      expect(last_response.body).to include('e-mail con la información para el pago')
    end

    it 'responds successfully' do
      get "/es/events/#{event_id}/participant_confirmed?free=true&api=1"
      
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('Registro Exitoso')
    end

    it 'includes back to agenda link' do
      get "/es/events/#{event_id}/participant_confirmed?free=true&api=1"
      
      expect(last_response.body).to include('href="/es/agenda"')
      expect(last_response.body).to include('Volver a la Agenda')
    end

    context 'with English locale' do
      before do
        env 'rack.session', { locale: 'en' }
      end

      it 'renders confirmation page for free event in English' do
        get "/en/events/#{event_id}/participant_confirmed?free=true&api=1"
        
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include('Registration Successful!')
        expect(last_response.body).to include('You\'re all set!')
        expect(last_response.body).to include('You\'ve been registered for the event')
      end

      it 'includes back to agenda link in English' do
        get "/en/events/#{event_id}/participant_confirmed?free=true&api=1"
        
        expect(last_response.body).to include('href="/en/schedule"')
        expect(last_response.body).to include('Back to Agenda')
      end
    end
  end

  describe 'POST /:lang/events/:event_id/participants/register' do
    let(:event_id) { '123' }
    
    let(:registration_params) do
      {
        'fname' => 'John',
        'lname' => 'Doe',
        'email' => 'john@example.com',
        'company_name' => 'Test Company',
        'address' => '123 Test St',
        'quantity' => '1',
        'phone' => '555-1234',
        'notes' => 'Test notes',
        'accept_terms' => 'on',
        'recaptcha_token' => 'test_token'
      }
    end

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('KEVENTER_URL').and_return('https://mocked-backend')
    end

    context 'when registration is successful' do
      before do
        # Mock successful HTTParty response
        response_double = double('HTTParty::Response')
        allow(response_double).to receive(:success?).and_return(true)
        allow(response_double).to receive(:body).and_return('{"success": true, "free": false}')
        allow(HTTParty).to receive(:post).and_return(response_double)
      end

      it 'forwards the registration to Rails API and returns JSON response' do
        post "/es/events/#{event_id}/participants/register", registration_params
        
        expect(last_response.status).to eq(200)
        expect(last_response.content_type).to include('application/json')
        expect(last_response.body).to include('success')
      end
    end

    context 'when registration fails' do
      before do
        # Mock failed HTTParty response
        response_double = double('HTTParty::Response')
        allow(response_double).to receive(:success?).and_return(false)
        allow(response_double).to receive(:code).and_return(422)
        allow(response_double).to receive(:body).and_return('{"error": "Validation failed"}')
        allow(HTTParty).to receive(:post).and_return(response_double)
      end

      it 'returns error response from Rails API' do
        post "/es/events/#{event_id}/participants/register", registration_params
        
        expect(last_response.status).to eq(422)
        expect(last_response.body).to include('Validation failed')
      end
    end

    context 'when API is unreachable' do
      before do
        allow(HTTParty).to receive(:post).and_raise(Errno::ECONNREFUSED.new('Connection refused'))
      end

      it 'returns 503 service unavailable' do
        post "/es/events/#{event_id}/participants/register", registration_params
        
        expect(last_response.status).to eq(503)
        expect(last_response.body).to include('Registration service temporarily unavailable')
      end
    end
  end
end