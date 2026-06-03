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

    describe 'card_description field' do
      it 'loads card_description from JSON when present' do
        service_data['card_description'] = '<section class="rw-section"><h2>Programa</h2></section>'
        service = ServiceV3.new(service_data)
        expect(service.card_description).to include('Programa')
      end

      it 'is nil when absent' do
        expect(ServiceV3.new(service_data).card_description).to be_nil
      end
    end

    describe 'forma recomendada fields' do
      it 'loads recommended way fields from JSON when present' do
        service_data['recommended_way_title'] = 'Membresía IA'
        service_data['recommended_way_note'] = '80%'
        service_data['recommended_way_summary'] = '<ol><li>Paso 1</li></ol>'
        service_data['recommended_way_details'] = '<p>Full guide</p>'
        service = ServiceV3.new(service_data)
        expect(service.recommended_way_title).to eq('Membresía IA')
        expect(service.recommended_way_note).to eq('80%')
        expect(service.recommended_way_summary).to include('Paso 1')
        expect(service.recommended_way_details).to include('Full guide')
      end
    end
  end
end