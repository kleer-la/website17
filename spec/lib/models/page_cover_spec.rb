require_relative '../../spec_helper'
require './lib/models/page'

RSpec.describe Page do
  describe '#cover' do
    let(:page_data) do
      {
        'lang' => 'es',
        'seo_title' => 'Test Page',
        'cover' => 'https://kleer-images.s3.sa-east-1.amazonaws.com/page-cover.jpg',
        'recommended' => []
      }
    end

    let(:page) { Page.new(page_data) }

    it 'replaces S3 URLs with CDN URLs' do
      expect(page.cover).to eq('https://d3vnsn21cv5bcd.cloudfront.net/page-cover.jpg')
    end

    it 'handles nil values' do
      page_data['cover'] = nil
      page = Page.new(page_data)
      expect(page.cover).to be_nil
    end

    it 'handles empty strings (converted to nil by empty_to_nil)' do
      page_data['cover'] = ''
      page = Page.new(page_data)
      expect(page.cover).to be_nil
    end

    it 'preserves existing CDN URLs' do
      page_data['cover'] = 'https://d3vnsn21cv5bcd.cloudfront.net/already-cdn.jpg'
      page = Page.new(page_data)
      expect(page.cover).to eq('https://d3vnsn21cv5bcd.cloudfront.net/already-cdn.jpg')
    end
  end
end