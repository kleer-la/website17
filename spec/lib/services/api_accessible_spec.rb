require 'spec_helper'
require './lib/services/api_accessible'

RSpec.describe APIAccessible do
  let(:dummy_class) do
    Class.new do
      include APIAccessible
      api_connector(Class.new { def url_for(id) = "https://api.example.com/resource/#{id}" })

      attr_reader :data

      def initialize(data)
        @data = data
      end
    end
  end
  after(:each) do
    CacheService.clear
  end

  describe '.create_from_api' do
    context 'when API call is successful' do
      before do
        successful_response = instance_double(HTTParty::Response, success?: true,
                                                                  parsed_response: { 'id' => 1, 'name' => 'Test' })
        allow(APIAccessible::JsonAPI).to receive(:get).and_return(successful_response)
      end

      it 'creates an object from API data' do
        object = dummy_class.create_from_api(1)
        expect(object.data).to eq({ 'id' => 1, 'name' => 'Test' })
      end
    end

    context 'when API call fails' do
      # Move the double creation into the example to ensure isolation
      it 'returns nil' do
        failed_response = instance_double(HTTParty::Response, success?: false)
        allow(APIAccessible::JsonAPI).to receive(:get).and_return(failed_response)
        
        object = dummy_class.create_from_api(1)
        expect(object).to be_nil
      end
    end
  end

  describe '.null_json_api' do
    it 'allows setting a null API for testing' do
      null_api = APIAccessible::NullJsonAPI.new('{"id": 2, "name": "Test 2"}')
      dummy_class.null_json_api(null_api)
      object = dummy_class.create_from_api(2)
      expect(object.data).to eq({ 'id' => 2, 'name' => 'Test 2' })
    end
  end
end