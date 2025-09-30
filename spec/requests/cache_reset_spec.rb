require 'spec_helper'
require './app'

describe 'Cache Reset Endpoint' do
  def app
    Sinatra::Application.new
  end

  describe 'GET /cache-reset' do
    let(:valid_token) { 'secret-cache-token-123' }

    before do
      allow(ENV).to receive(:[]).and_call_original
    end

    context 'when CACHE_RESET_TOKEN is not configured' do
      before do
        allow(ENV).to receive(:[]).with('CACHE_RESET_TOKEN').and_return(nil)
      end

      it 'returns 503 service unavailable' do
        get '/cache-reset?token=any-token'

        expect(last_response.status).to eq(503)
        expect(last_response.body).to include('Cache reset not configured')
      end
    end

    context 'when CACHE_RESET_TOKEN is configured' do
      before do
        allow(ENV).to receive(:[]).with('CACHE_RESET_TOKEN').and_return(valid_token)
      end

      context 'when token is missing' do
        it 'returns 403 forbidden' do
          get '/cache-reset'

          expect(last_response.status).to eq(403)
          expect(last_response.body).to include('Invalid token')
        end
      end

      context 'when token is invalid' do
        it 'returns 403 forbidden' do
          get '/cache-reset?token=wrong-token'

          expect(last_response.status).to eq(403)
          expect(last_response.body).to include('Invalid token')
        end
      end

      context 'when token is valid' do
        before do
          # Populate cache with some test data
          CacheService.set('test_key_1', 'value1')
          CacheService.set('test_key_2', 'value2')
        end

        it 'clears the cache and returns success' do
          get "/cache-reset?token=#{valid_token}"

          expect(last_response.status).to eq(200)
          expect(last_response.content_type).to include('application/json')

          json_response = JSON.parse(last_response.body)
          expect(json_response['status']).to eq('ok')
          expect(json_response['message']).to eq('Cache cleared successfully')
          expect(json_response['stats']).to be_a(Hash)
          expect(json_response['stats']['total_entries']).to eq(0)
        end

        it 'actually clears the cache' do
          # Verify cache has data
          expect(CacheService.get('test_key_1')).to eq('value1')

          get "/cache-reset?token=#{valid_token}"

          # Verify cache is empty
          expect(CacheService.get('test_key_1')).to be_nil
          expect(CacheService.get('test_key_2')).to be_nil
        end

        it 'returns cache stats after clearing' do
          get "/cache-reset?token=#{valid_token}"

          json_response = JSON.parse(last_response.body)
          expect(json_response['stats']['total_entries']).to eq(0)
          expect(json_response['stats']['valid_entries']).to eq(0)
          expect(json_response['stats']['expired_entries']).to eq(0)
        end
      end
    end

    context 'with empty token parameter' do
      before do
        allow(ENV).to receive(:[]).with('CACHE_RESET_TOKEN').and_return(valid_token)
      end

      it 'returns 403 forbidden' do
        get '/cache-reset?token='

        expect(last_response.status).to eq(403)
        expect(last_response.body).to include('Invalid token')
      end
    end
  end
end
