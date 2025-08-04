require 'spec_helper'
require './app'

describe 'Participant Registration' do
  def app
    Sinatra::Application.new
  end

  describe 'GET /events/:event_id/participants/register' do
    let(:event_id) { '123' }
    let(:backend_api_url) { 'http://localhost:3000' }
    
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
      allow(ENV).to receive(:[]).with('KEVENTER_URL').and_return(backend_api_url)
      allow(ENV).to receive(:[]).with('RECAPTCHA_SITE_KEY').and_return('test_site_key')
    end

    context 'when event exists' do
      before do
        # Mock HTTParty response for event data
        event_response = double('HTTParty::Response')
        allow(event_response).to receive(:success?).and_return(true)
        allow(event_response).to receive(:parsed_response).and_return(mock_event_data)
        allow(HTTParty).to receive(:get).with("#{backend_api_url}/api/events/#{event_id}", headers: { 'Accept' => 'application/json' }).and_return(event_response)
        
        # Mock HTTParty response for pricing data (1-6 quantities)
        pricing_response = double('HTTParty::Response')
        allow(pricing_response).to receive(:success?).and_return(true)
        allow(pricing_response).to receive(:parsed_response).and_return({
          'unit_price' => 100,
          'total_price' => 100,
          'currency' => 'USD',
          'savings' => 0
        })
        
        (1..6).each do |qty|
          allow(HTTParty).to receive(:get).with("#{backend_api_url}/api/v3/events/#{event_id}/participants/pricing_info?quantity=#{qty}", headers: { 'Accept' => 'application/json' }).and_return(pricing_response)
        end
        
        # Setup session
        env 'rack.session', { locale: 'es' }
      end

      it 'renders the registration form' do
        get "/events/#{event_id}/participants/register"
        
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
        get "/events/#{event_id}/participants/register"
        
        expect(last_response.body).to include('name="referer_code"')
      end

      it 'shows sold out warning when event is sold out' do
        mock_event_data['is_sold_out'] = true
        
        get "/events/#{event_id}/participants/register"
        
        expect(last_response.body).to include('Este evento está completo')
      end

      it 'shows registration ended warning when registration has ended' do
        mock_event_data['registration_ended'] = true
        
        get "/events/#{event_id}/participants/register"
        
        expect(last_response.body).to include('La fecha de registración ha pasado')
      end

      it 'responds successfully with form content' do
        get "/events/#{event_id}/participants/register"
        
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include('Test Course')
        expect(last_response.body).to include('form')
      end
    end

    context 'when event does not exist' do
      before do
        # Mock HTTParty response for non-existent event
        response_double = double('HTTParty::Response')
        allow(response_double).to receive(:success?).and_return(false)
        allow(HTTParty).to receive(:get).with("#{backend_api_url}/api/events/999", headers: { 'Accept' => 'application/json' }).and_return(response_double)
      end

      it 'returns 404 error' do
        get "/events/999/participants/register"
        
        expect(last_response.status).to eq(404)
      end
    end

    context 'when API is unreachable' do
      before do
        allow(HTTParty).to receive(:get).and_raise(StandardError.new('Connection failed'))
      end

      it 'returns 503 service unavailable' do
        get "/events/#{event_id}/participants/register"
        
        expect(last_response.status).to eq(503)
        expect(last_response.body).to include('Service temporarily unavailable')
      end
    end
  end

  describe 'GET /events/:event_id/participant_confirmed' do
    let(:event_id) { '123' }

    before do
      env 'rack.session', { locale: 'es' }
    end

    it 'renders confirmation page for free event' do
      get "/events/#{event_id}/participant_confirmed?free=true&api=1"
      
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('¡Registro Exitoso!')
      expect(last_response.body).to include('¡Listo!')
      expect(last_response.body).to include('Has sido registrado para el evento')
    end

    it 'renders confirmation page for paid event' do
      get "/events/#{event_id}/participant_confirmed?free=false&api=1"
      
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('¡Registro Exitoso!')
      expect(last_response.body).to include('¡Gracias!')
      expect(last_response.body).to include('e-mail con la información para el pago')
    end

    it 'responds successfully' do
      get "/events/#{event_id}/participant_confirmed?free=true&api=1"
      
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('Registro Exitoso')
    end

    it 'includes back to agenda link' do
      get "/events/#{event_id}/participant_confirmed?free=true&api=1"
      
      expect(last_response.body).to include('href="/es/agenda"')
      expect(last_response.body).to include('Volver a la Agenda')
    end
  end

  describe 'POST /events/:event_id/participants/register' do
    let(:event_id) { '123' }
    let(:backend_api_url) { 'http://localhost:3000' }
    
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
      allow(ENV).to receive(:[]).with('KEVENTER_URL').and_return(backend_api_url)
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
        post "/events/#{event_id}/participants/register", registration_params
        
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
        post "/events/#{event_id}/participants/register", registration_params
        
        expect(last_response.status).to eq(422)
        expect(last_response.body).to include('Validation failed')
      end
    end

    context 'when API is unreachable' do
      before do
        allow(HTTParty).to receive(:post).and_raise(Errno::ECONNREFUSED.new('Connection refused'))
      end

      it 'returns 503 service unavailable' do
        post "/events/#{event_id}/participants/register", registration_params
        
        expect(last_response.status).to eq(503)
        expect(last_response.body).to include('Registration service temporarily unavailable')
      end
    end
  end
end