require 'spec_helper'
require 'sinatra/flash'
require './app'
require './lib/services/booking_token'
require './lib/services/mailer'

describe 'Bookings' do
  def app
    Sinatra::Application.new
  end

  let(:service_area_data) do
    {
      'id' => 42,
      'slug' => 'agile-coaching',
      'name' => 'Agile Coaching',
      'lang' => 'es',
      'primary_color' => '#FF5733',
      'primary_font_color' => '#FFFFFF',
      'secondary_color' => '#33FF57',
      'secondary_font_color' => '#000000',
      'seo_title' => 'Agile Coaching',
      'seo_description' => 'Coaching services',
      'is_training_program' => false,
      'services' => []
    }
  end

  let(:consultants_data) do
    [
      { 'id' => 1, 'name' => 'Jane Doe', 'gravatar_email' => 'jane@example.com', 'bio' => 'Coach' },
      { 'id' => 2, 'name' => 'John Smith', 'gravatar_email' => 'john@example.com', 'bio' => 'Trainer' }
    ]
  end

  let(:null_service_area_api) { NullJsonAPI.new(nil, service_area_data.to_json) }

  before do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('CONTACT_US_SECRET').and_return('test-secret')
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('RECAPTCHA_SITE_KEY').and_return('test-site-key')
    env 'rack.session', { locale: 'es' }
  end

  after do
    ServiceAreaV3.class_variable_set(:@@json_api, nil) if ServiceAreaV3.class_variable_defined?(:@@json_api)
  end

  describe 'GET /agendar/:slug' do
    before do
      ServiceAreaV3.null_json_api(nil, null_service_area_api)
      allow(JsonAPI).to receive(:new).and_call_original
      consultants_response = NullJsonAPI.new(nil, consultants_data.to_json)
      allow(JsonAPI).to receive(:new)
        .with(KeventerAPI.service_area_consultants_url('agile-coaching'))
        .and_return(consultants_response)
    end

    it 'returns 404 without a token' do
      get '/es/agendar/agile-coaching'
      expect(last_response.status).to eq(404)
    end

    it 'returns 404 with an invalid token' do
      get '/es/agendar/agile-coaching?token=invalid'
      expect(last_response.status).to eq(404)
    end

    it 'returns 404 with an expired token' do
      token = BookingToken.generate(email: 'user@test.com', area_slug: 'agile-coaching')
      allow(Time).to receive(:now).and_return(Time.now + 31 * 60)

      get "/es/agendar/agile-coaching?token=#{token}"
      expect(last_response.status).to eq(404)
    end

    it 'renders consultants with a valid token' do
      token = BookingToken.generate(email: 'user@test.com', area_slug: 'agile-coaching')
      get "/es/agendar/agile-coaching?token=#{token}"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('consultant-card')
      expect(last_response.body).to include('Jane Doe')
    end

    it 'renders valid JS when visitor message contains newlines and quotes' do
      token = BookingToken.generate(
        email: 'user@test.com',
        area_slug: 'agile-coaching',
        name: "O'Brien",
        message: "Line one\r\nLine two\nLine \"three\""
      )
      get "/es/agendar/agile-coaching?token=#{token}"

      expect(last_response.status).to eq(200)
      body = last_response.body
      # Extract BOOKING_CONFIG block and verify it's valid JS (no unescaped characters)
      config_match = body.match(/var BOOKING_CONFIG = \{(.+?)\};/m)
      expect(config_match).not_to be_nil
      config_block = config_match[0]
      expect(config_block).not_to include("\r")
      expect(config_block).to include('O\\u0027Brien').or include("O'Brien") # .to_json escapes quotes
    end

    context 'with nonexistent service area' do
      before do
        null_api = NullJsonAPI.new(nil, nil)
        ServiceAreaV3.null_json_api(nil, null_api)
      end

      it 'returns 404' do
        token = BookingToken.generate(email: 'user@test.com', area_slug: 'nonexistent-slug')
        get "/es/agendar/nonexistent-slug?token=#{token}"
        expect(last_response.status).to eq(404)
      end
    end
  end

  describe 'POST /qualify-booking' do
    let(:mailer_instance) { instance_double(Mailer) }

    before do
      allow_any_instance_of(Sinatra::Application).to receive(:verify_recaptcha).and_return(true)
      allow(Mailer).to receive(:new).and_return(mailer_instance)
      env 'rack.session', { locale: 'es', flash: {} }
    end

    context 'with consultants and description >= 50 chars' do
      before do
        consultants_response = NullJsonAPI.new(nil, consultants_data.to_json)
        allow(JsonAPI).to receive(:new)
          .with(KeventerAPI.service_area_consultants_url('agile-coaching'))
          .and_return(consultants_response)
      end

      it 'redirects with a token' do
        post '/es/qualify-booking', {
          'name' => 'Test User',
          'email' => 'test@example.com',
          'company' => 'TestCo',
          'message' => 'A' * 50,
          'area_slug' => 'agile-coaching',
          'context' => '/servicios/agile-coaching'
        }

        expect(last_response.status).to eq(302)
        expect(last_response.location).to include('/es/agendar/agile-coaching?token=')
      end
    end

    context 'with description < 50 chars' do
      it 'sends mail and redirects to context page' do
        expect(Mailer).to receive(:new).with(
          KeventerAPI.mailer_url,
          hash_including(name: 'Test User', email: 'test@example.com')
        )

        post '/es/qualify-booking', {
          'name' => 'Test User',
          'email' => 'test@example.com',
          'company' => 'TestCo',
          'message' => 'Help needed',
          'message' => 'Short',
          'area_slug' => 'agile-coaching',
          'context' => '/servicios/agile-coaching'
        }

        expect(last_response.status).to eq(302)
        expect(last_response.location).to include('/servicios/agile-coaching')
        expect(last_response.location).not_to include('token=')
      end
    end

    context 'without area_slug (non-service-area page)' do
      it 'sends mail and redirects to context' do
        expect(Mailer).to receive(:new).with(
          KeventerAPI.mailer_url,
          hash_including(name: 'Test User')
        )

        post '/es/qualify-booking', {
          'name' => 'Test User',
          'email' => 'test@example.com',
          'message' => 'General question',
          'message' => '',
          'area_slug' => '',
          'context' => '/somos'
        }

        expect(last_response.status).to eq(302)
        expect(last_response.location).to include('/somos')
      end
    end

    context 'with invalid recaptcha' do
      before do
        allow_any_instance_of(Sinatra::Application).to receive(:verify_recaptcha).and_return(false)
      end

      it 'redirects with error to context page' do
        post '/es/qualify-booking', {
          'name' => 'Test User',
          'email' => 'test@example.com',
          'message' => 'Some text',
          'area_slug' => '',
          'context' => '/servicios/agile-coaching'
        }

        expect(last_response.status).to eq(302)
        expect(last_response.location).to include('/servicios/agile-coaching')
      end
    end
  end

  describe 'GET /consultant-availability/:id' do
    it 'returns 403 without a valid token' do
      get '/es/consultant-availability/1'
      expect(last_response.status).to eq(403)
    end

    it 'proxies the API response with a valid token' do
      token = BookingToken.generate(email: 'user@test.com', area_slug: 'agile-coaching')
      availability_data = [{ 'start_time' => '2026-04-20T10:00:00Z' }]
      availability_response = NullJsonAPI.new(nil, availability_data.to_json)

      allow(JsonAPI).to receive(:new).and_return(availability_response)

      get "/es/consultant-availability/1?token=#{token}&area_slug=agile-coaching&start=2026-04-16&end=2026-04-30&timezone=America/Buenos_Aires"

      expect(last_response.status).to eq(200)
      parsed = JSON.parse(last_response.body)
      expect(parsed).to be_an(Array)
    end
  end

  describe 'POST /book-meeting' do
    it 'returns 403 without a valid token' do
      post '/es/book-meeting', { 'consultant_id' => '1' }
      expect(last_response.status).to eq(403)
    end
  end

  describe 'POST /send-booking-inquiry' do
    before do
      env 'rack.session', { locale: 'es', flash: {} }
    end

    it 'returns 403 without a valid token' do
      post '/es/send-booking-inquiry', { 'area_slug' => 'agile-coaching' }
      expect(last_response.status).to eq(403)
    end

    it 'redirects with a valid token without resending mail' do
      token = BookingToken.generate(email: 'user@test.com', area_slug: 'agile-coaching')

      expect(Mailer).not_to receive(:new)

      post '/es/send-booking-inquiry', {
        'booking_token' => token,
        'area_slug' => 'agile-coaching',
        'name' => 'Test User',
        'email' => 'test@example.com',
        'message' => 'Please help us'
      }

      expect(last_response.status).to eq(302)
      expect(last_response.location).to include('/agendar/agile-coaching')
    end
  end
end
