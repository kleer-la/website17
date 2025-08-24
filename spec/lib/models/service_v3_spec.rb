require_relative '../../spec_helper'
require './lib/models/service_v3'

RSpec.describe ServiceV3 do
  describe 'image URL replacement' do
    let(:service_data) do
      {
        'id' => 1,
        'name' => 'Test Service',
        'brochure' => 'https://kleer-images.s3.sa-east-1.amazonaws.com/service-brochure.pdf',
        'side_image' => 'https://kleer-images.s3.sa-east-1.amazonaws.com/service-image.jpg',
        'recommended' => []
      }
    end

    let(:service) { ServiceV3.new(service_data) }

    describe '#brochure' do
      it 'replaces S3 URLs with CDN URLs' do
        expect(service.brochure).to eq('https://d3vnsn21cv5bcd.cloudfront.net/service-brochure.pdf')
      end

      it 'handles nil values' do
        service_data['brochure'] = nil
        service = ServiceV3.new(service_data)
        expect(service.brochure).to be_nil
      end
    end

    describe '#side_image' do
      it 'replaces S3 URLs with CDN URLs' do
        expect(service.side_image).to eq('https://d3vnsn21cv5bcd.cloudfront.net/service-image.jpg')
      end

      it 'handles empty strings' do
        service_data['side_image'] = ''
        service = ServiceV3.new(service_data)
        expect(service.side_image).to eq('')
      end
    end
  end
end