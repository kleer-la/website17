require 'spec_helper'
require './lib/helpers/event_helper'

describe EventHelper do
  include EventHelper
  
  describe '#calculate_event_pricing' do
    let(:event_type) { double('EventType', coupons: []) }
    let(:event) do
      double('Event',
             list_price: 100,
             eb_price: 80,
             eb_date: '2025-03-20',
             event_type: event_type,
             currency_iso_code: 'USD')
    end

    context 'when EB date is in the future' do
      it 'shows EB price' do
        pricing = calculate_event_pricing(event, Date.parse('2025-03-18'))
        expect(pricing[:show_eb_price]).to be true
        expect(pricing[:final_price]).to eq(80)
      end
    end

    context 'when EB date is in the past' do
      it 'does not show EB price' do
        pricing = calculate_event_pricing(event, Date.parse('2025-03-21'))
        expect(pricing[:show_eb_price]).to be false
        expect(pricing[:final_price]).to eq(100)
      end
    end

    context 'when coupon offers a better price' do
      let(:coupon) { double('Coupon', percent_off: 50, icon: 'icon.png') }
      before { allow(event_type).to receive(:coupons).and_return([coupon]) }

      it 'uses coupon price' do
        pricing = calculate_event_pricing(event, Date.parse('2025-03-18'))
        expect(pricing[:using_coupon]).to be true
        expect(pricing[:final_price]).to eq(50)
      end
    end
  end
end