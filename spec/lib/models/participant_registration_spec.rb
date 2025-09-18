require 'spec_helper'
require './lib/models/participant_registration'
require './lib/services/keventer_api'
require './lib/services/cache_service'
require './lib/services/api_accessible'

RSpec.describe ParticipantRegistration do
  let(:valid_event_data) do
    {
      'id' => '123',
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

  let(:valid_pricing_data) do
    {
      'unit_price' => 100,
      'total_price' => 100,
      'currency' => 'USD',
      'savings' => 0
    }
  end

  let(:valid_registration_params) do
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

  describe '.new' do
    it 'creates a ParticipantRegistration object with event_id' do
      registration = ParticipantRegistration.new('123')
      expect(registration.event_id).to eq('123')
    end
  end

  describe '.load_event_data' do
    context 'when API call is successful' do
      it 'returns event data' do
        ParticipantRegistration.api_client = APIAccessible::NullJsonAPI.new(valid_event_data.to_json)

        registration = ParticipantRegistration.new('123')
        event_data = registration.load_event_data('es')

        expect(event_data).to be_a(Hash)
        expect(event_data['id']).to eq('123')
        expect(event_data['event_type']['name']).to eq('Test Course')
      end
    end

    context 'when API call fails' do
      it 'returns nil' do
        null_api = APIAccessible::NullJsonAPI.new("{}")
        allow(null_api).to receive(:ok?).and_return(false)
        ParticipantRegistration.api_client = null_api

        registration = ParticipantRegistration.new('123')
        event_data = registration.load_event_data('es')

        expect(event_data).to be_nil
      end
    end
  end

  describe '.load_pricing_data' do
    context 'when API call is successful' do
      it 'returns pricing data for specified quantity' do
        ParticipantRegistration.api_client = APIAccessible::NullJsonAPI.new(valid_pricing_data.to_json)

        registration = ParticipantRegistration.new('123')
        pricing_data = registration.load_pricing_data(2)

        expect(pricing_data).to be_a(Hash)
        expect(pricing_data['unit_price']).to eq(100)
        expect(pricing_data['total_price']).to eq(100)
      end
    end

    context 'when API call fails' do
      it 'returns nil' do
        null_api = APIAccessible::NullJsonAPI.new("{}")
        allow(null_api).to receive(:ok?).and_return(false)
        ParticipantRegistration.api_client = null_api

        registration = ParticipantRegistration.new('123')
        pricing_data = registration.load_pricing_data(2)

        expect(pricing_data).to be_nil
      end
    end
  end

  describe '.submit_registration' do
    context 'when API call is successful' do
      let(:success_response) { '{"success": true, "free": false}' }

      it 'returns success response' do
        ParticipantRegistration.api_client = APIAccessible::NullJsonAPI.new(success_response)

        registration = ParticipantRegistration.new('123')
        response = registration.submit_registration(valid_registration_params)

        expect(response[:success]).to be true
        expect(response[:body]).to include('success')
        expect(response[:status]).to eq(200)
      end
    end

    context 'when API call fails with validation error' do
      it 'returns service unavailable response when using test client' do
        # In test mode, failed API client calls are treated as service unavailable
        null_api = APIAccessible::NullJsonAPI.new('{"error": "Validation failed"}')
        allow(null_api).to receive(:ok?).and_return(false)
        ParticipantRegistration.api_client = null_api

        registration = ParticipantRegistration.new('123')
        response = registration.submit_registration(valid_registration_params)

        expect(response[:success]).to be false
        expect(response[:body]).to include('Registration service temporarily unavailable')
        expect(response[:status]).to eq(503)
      end
    end

    context 'when API is unreachable' do
      it 'returns service unavailable response' do
        null_api = APIAccessible::NullJsonAPI.new("{}")
        allow(null_api).to receive(:ok?).and_return(false)
        ParticipantRegistration.api_client = null_api

        registration = ParticipantRegistration.new('123')
        response = registration.submit_registration(valid_registration_params)

        expect(response[:success]).to be false
        expect(response[:body]).to include('Registration service temporarily unavailable')
        expect(response[:status]).to eq(503)
      end
    end
  end

  describe 'caching behavior' do
    before do
      CacheService.clear
      ParticipantRegistration.api_client = nil
    end

    it 'caches event data API responses' do
      call_count = 0

      allow(APIAccessible::JsonAPI).to receive(:new) do |url|
        call_count += 1
        APIAccessible::NullJsonAPI.new(valid_event_data.to_json)
      end

      allow(KeventerAPI).to receive(:event_url).and_return('https://api.example.com/events/123')

      registration = ParticipantRegistration.new('123')
      registration.load_event_data('es')
      registration.load_event_data('es') # Second call should use cache

      expect(call_count).to eq(1)
    end

    it 'caches pricing data API responses' do
      call_count = 0

      allow(APIAccessible::JsonAPI).to receive(:new) do |url|
        call_count += 1
        APIAccessible::NullJsonAPI.new(valid_pricing_data.to_json)
      end

      allow(KeventerAPI).to receive(:participant_pricing_url).and_return('https://api.example.com/pricing')

      registration = ParticipantRegistration.new('123')
      registration.load_pricing_data(2)
      registration.load_pricing_data(2) # Second call should use cache

      expect(call_count).to eq(1)
    end
  end
end