require 'spec_helper'
require './lib/services/booking_token'

describe BookingToken do
  before do
    allow(ENV).to receive(:fetch).with('CONTACT_US_SECRET').and_return('test-secret-key-123')
  end

  describe '.generate' do
    it 'returns a Base64-encoded string' do
      token = BookingToken.generate(email: 'user@example.com', area_slug: 'agile-coaching')
      expect(token).to be_a(String)
      expect { Base64.urlsafe_decode64(token) }.not_to raise_error
    end
  end

  describe '.valid?' do
    it 'accepts a freshly generated token with matching area_slug' do
      token = BookingToken.generate(email: 'user@example.com', area_slug: 'agile-coaching')
      result = BookingToken.valid?(token, area_slug: 'agile-coaching')
      expect(result).to be_a(Hash)
      expect(result['email']).to eq('user@example.com')
      expect(result['area_slug']).to eq('agile-coaching')
    end

    it 'rejects a token with a different area_slug' do
      token = BookingToken.generate(email: 'user@example.com', area_slug: 'agile-coaching')
      expect(BookingToken.valid?(token, area_slug: 'other-area')).to be false
    end

    it 'rejects an expired token (>30 min)' do
      token = BookingToken.generate(email: 'user@example.com', area_slug: 'agile-coaching')
      allow(Time).to receive(:now).and_return(Time.now + 31 * 60)
      expect(BookingToken.valid?(token, area_slug: 'agile-coaching')).to be false
    end

    it 'rejects a tampered token' do
      token = BookingToken.generate(email: 'user@example.com', area_slug: 'agile-coaching')
      tampered = token[0..-2] + (token[-1] == 'A' ? 'B' : 'A')
      expect(BookingToken.valid?(tampered, area_slug: 'agile-coaching')).to be false
    end

    it 'rejects nil token' do
      expect(BookingToken.valid?(nil, area_slug: 'agile-coaching')).to be false
    end

    it 'rejects empty token' do
      expect(BookingToken.valid?('', area_slug: 'agile-coaching')).to be false
    end

    it 'rejects garbage input' do
      expect(BookingToken.valid?('not-a-valid-token!!!', area_slug: 'agile-coaching')).to be false
    end
  end

  describe '.secret' do
    it 'raises when CONTACT_US_SECRET is not set' do
      allow(ENV).to receive(:fetch).with('CONTACT_US_SECRET').and_call_original
      # Temporarily remove the env var
      allow(ENV).to receive(:fetch).with('CONTACT_US_SECRET').and_raise(KeyError.new('key not found: "CONTACT_US_SECRET"'))
      expect { BookingToken.secret }.to raise_error(KeyError)
    end
  end
end
