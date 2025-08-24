require_relative '../../spec_helper'
require './lib/models/service_area_v3'

RSpec.describe ServiceAreaV3 do
  describe 'image URL replacement' do
    let(:service_area_data) do
      {
        'id' => 1,
        'slug' => 'test-service',
        'name' => 'Test Service Area',
        'icon' => 'https://kleer-images.s3.sa-east-1.amazonaws.com/service-icon.png',
        'side_image' => 'https://kleer-images.s3.sa-east-1.amazonaws.com/dla%20grupo%20lideres%20interactuando.png',
        'services' => []
      }
    end

    let(:service_area) { ServiceAreaV3.new.load_from_json(service_area_data) }

    describe '#icon' do
      it 'replaces S3 URLs with CDN URLs' do
        expect(service_area.icon).to eq('https://d3vnsn21cv5bcd.cloudfront.net/service-icon.png')
      end

      it 'handles nil values' do
        service_area_data['icon'] = nil
        expect(service_area.icon).to be_nil
      end

      it 'handles empty strings' do
        service_area_data['icon'] = ''
        expect(service_area.icon).to eq('')
      end
    end

    describe '#side_image' do
      it 'replaces S3 URLs with CDN URLs including URL encoded characters' do
        expect(service_area.side_image).to eq('https://d3vnsn21cv5bcd.cloudfront.net/dla%20grupo%20lideres%20interactuando.png')
      end

      it 'preserves existing CDN URLs' do
        service_area_data['side_image'] = 'https://d3vnsn21cv5bcd.cloudfront.net/already-cdn.png'
        service_area = ServiceAreaV3.new.load_from_json(service_area_data)
        expect(service_area.side_image).to eq('https://d3vnsn21cv5bcd.cloudfront.net/already-cdn.png')
      end
    end
  end
end