require_relative '../../spec_helper'
require './lib/models/coupon'

RSpec.describe Coupon do
  describe '#icon' do
    it 'replaces S3 URLs with CDN URLs' do
      coupon = Coupon.new('TEST10', 10, 'https://kleer-images.s3.sa-east-1.amazonaws.com/coupon-icon.png')
      
      expect(coupon.icon).to eq('https://d3vnsn21cv5bcd.cloudfront.net/coupon-icon.png')
    end

    it 'handles nil values' do
      coupon = Coupon.new('TEST10', 10, nil)
      
      expect(coupon.icon).to be_nil
    end

    it 'handles empty strings' do
      coupon = Coupon.new('TEST10', 10, '')
      
      expect(coupon.icon).to eq('')
    end

    it 'preserves existing CDN URLs' do
      coupon = Coupon.new('TEST10', 10, 'https://d3vnsn21cv5bcd.cloudfront.net/already-cdn.png')
      
      expect(coupon.icon).to eq('https://d3vnsn21cv5bcd.cloudfront.net/already-cdn.png')
    end
  end
end