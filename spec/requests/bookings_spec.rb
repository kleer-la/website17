require 'spec_helper'
require 'sinatra/flash'
require './app'
require './lib/models/consultant'
require './lib/services/booking_service'

describe 'Bookings' do
  def app
    Sinatra::Application.new
  end

  before do
    Toggle.turn('booking', true)
    env 'rack.session', { locale: 'es' }
  end

  after do
    Toggle.turn('booking', false)
    Consultant.api_client = nil
  end

  describe 'GET /agendar/:area_slug' do
    let(:service_area_json) do
      {
        'id' => 1, 'slug' => 'agile-coaching', 'lang' => 'es',
        'name' => 'Agile Coaching', 'summary' => 'Test',
        'primary_color' => '#275d74', 'primary_font_color' => '#ffffff',
        'secondary_color' => '#f0f0f0', 'secondary_font_color' => '#000000',
        'services' => [], 'testimonies' => [],
        'is_training_program' => false
      }
    end

    let(:consultants_json) do
      [
        { 'id' => 57, 'name' => 'Camilo Velasquez', 'bio' => 'Coach',
          'gravatar_email' => 'test@test.com', 'signature_credentials' => 'Agile Coach',
          'linkedin_url' => '' }
      ]
    end

    before do
      ServiceAreaV3.null_json_api(nil, NullJsonAPI.new(nil, service_area_json.to_json))
      Consultant.null_json_api(NullJsonAPI.new(nil, consultants_json.to_json))
      Page.api_client = NullJsonAPI.new(nil)
    end

    it 'renders the booking page' do
      get '/es/agendar/agile-coaching'
      expect(last_response.status).to eq 200
      expect(last_response.body).to include('Camilo Velasquez')
    end

    it 'returns 404 when feature is disabled' do
      Toggle.turn('booking', false)
      get '/es/agendar/agile-coaching'
      expect(last_response.status).to eq 404
    end
  end

  describe 'GET /consultant-availability/:id' do
    let(:availability_json) do
      {
        'consultant_id' => 57,
        'timezone' => 'America/Argentina/Buenos_Aires',
        'available_slots' => [
          { 'start' => '2026-04-16T09:00:00-03:00', 'end' => '2026-04-16T09:30:00-03:00' }
        ]
      }
    end

    it 'returns availability JSON' do
      Consultant.null_json_api(NullJsonAPI.new(nil, availability_json.to_json))
      get '/consultant-availability/57', { start: '2026-04-16', end: '2026-04-18' }
      expect(last_response.status).to eq 200
      expect(last_response.content_type).to include('application/json')
      body = JSON.parse(last_response.body)
      expect(body['available_slots'].length).to eq 1
    end

    it 'returns 400 without required params' do
      get '/consultant-availability/57'
      expect(last_response.status).to eq 400
    end

    it 'returns 404 when feature is disabled' do
      Toggle.turn('booking', false)
      get '/consultant-availability/57', { start: '2026-04-16', end: '2026-04-18' }
      expect(last_response.status).to eq 404
    end
  end

  describe 'POST /book-meeting' do
    let(:booking_instance) { instance_double(BookingService) }

    before do
      allow_any_instance_of(Sinatra::Application).to receive(:verify_recaptcha).and_return(true)
      allow(BookingService).to receive(:new).and_return(booking_instance)
    end

    it 'redirects with success flash on successful booking' do
      allow(booking_instance).to receive(:success?).and_return(true)
      allow(booking_instance).to receive(:consultant_name).and_return('Camilo')
      allow(booking_instance).to receive(:starts_at).and_return('2026-04-16T09:00:00-03:00')
      allow(booking_instance).to receive(:ends_at).and_return('2026-04-16T09:30:00-03:00')
      allow(booking_instance).to receive(:google_meet_link).and_return('https://meet.google.com/abc')

      post '/es/book-meeting', {
        name: 'John', email: 'john@test.com', consultant_id: '57',
        area_slug: 'agile-coaching', starts_at: '2026-04-16T09:00:00-03:00',
        ends_at: '2026-04-16T09:30:00-03:00'
      }

      expect(last_response.status).to eq 302
      expect(last_response.location).to include('/agendar/agile-coaching')
    end

    it 'redirects with error flash on failed booking' do
      allow(booking_instance).to receive(:success?).and_return(false)

      post '/es/book-meeting', {
        name: 'John', email: 'john@test.com', consultant_id: '57',
        area_slug: 'agile-coaching', starts_at: '2026-04-16T09:00:00-03:00',
        ends_at: '2026-04-16T09:30:00-03:00'
      }

      expect(last_response.status).to eq 302
    end

    it 'redirects with error when recaptcha fails' do
      allow_any_instance_of(Sinatra::Application).to receive(:verify_recaptcha).and_return(false)

      post '/es/book-meeting', {
        name: 'John', email: 'john@test.com', consultant_id: '57',
        area_slug: 'agile-coaching'
      }

      expect(last_response.status).to eq 302
    end
  end
end
