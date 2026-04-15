require 'spec_helper'
require './lib/services/booking_service'

describe BookingService do
  let(:consultant_id) { '57' }
  let(:booking_data) do
    {
      visitor_name: 'John Doe',
      visitor_email: 'john@example.com',
      visitor_company: 'Acme Corp',
      starts_at: '2026-04-16T09:00:00-03:00',
      ends_at: '2026-04-16T09:30:00-03:00',
      service_area_slug: 'agile-coaching',
      language: 'es'
    }
  end

  let(:success_body) do
    {
      'id' => 123,
      'status' => 'confirmed',
      'starts_at' => '2026-04-16T09:00:00-03:00',
      'ends_at' => '2026-04-16T09:30:00-03:00',
      'consultant_name' => 'Camilo Velasquez',
      'google_meet_link' => 'https://meet.google.com/abc-defg-hij'
    }
  end

  describe 'successful booking' do
    let(:response) { instance_double(Faraday::Response, status: 201, body: success_body.to_json) }

    before do
      allow(Faraday).to receive(:post).and_return(response)
    end

    it 'returns success' do
      booking = BookingService.new(consultant_id, booking_data)
      expect(booking.success?).to be true
    end

    it 'parses response fields' do
      booking = BookingService.new(consultant_id, booking_data)
      expect(booking.booking_id).to eq 123
      expect(booking.status).to eq 'confirmed'
      expect(booking.consultant_name).to eq 'Camilo Velasquez'
      expect(booking.google_meet_link).to eq 'https://meet.google.com/abc-defg-hij'
      expect(booking.starts_at).to eq '2026-04-16T09:00:00-03:00'
      expect(booking.ends_at).to eq '2026-04-16T09:30:00-03:00'
    end
  end

  describe 'failed booking' do
    let(:response) { instance_double(Faraday::Response, status: 422, body: '{"error":"Slot no longer available"}') }

    before do
      allow(Faraday).to receive(:post).and_return(response)
    end

    it 'returns failure' do
      booking = BookingService.new(consultant_id, booking_data)
      expect(booking.success?).to be false
    end
  end

  describe 'malformed response' do
    let(:response) { instance_double(Faraday::Response, status: 201, body: 'not json') }

    before do
      allow(Faraday).to receive(:post).and_return(response)
    end

    it 'handles parse errors gracefully' do
      booking = BookingService.new(consultant_id, booking_data)
      expect(booking.success?).to be true
      expect(booking.parsed_body).to eq({})
    end
  end
end
