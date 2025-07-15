require 'spec_helper'
require './lib/models/page'
require './lib/services/keventer_api'
require './lib/services/cache_service'

RSpec.describe Page do
  let(:valid_data) do
    {
      'lang' => 'en',
      'seo_title' => 'Test Title',
      'seo_description' => 'Test Description',
      'canonical' => 'https://example.com',
      'cover' => 'https://example.com/cover.jpg',
      'recommended' => []
    }
  end

  describe '.new' do
    it 'creates a Page object with given data' do
      page = Page.new(valid_data)
      expect(page.lang).to eq('en')
      expect(page.seo_title).to eq('Test Title')
      expect(page.seo_description).to eq('Test Description')
      expect(page.canonical).to eq('https://example.com')
      expect(page.cover).to eq('https://example.com/cover.jpg')
      expect(page.recommended).to be_an(Array)
    end

    it 'handles nil values' do
      page = Page.new({})
      expect(page.lang).to be_nil
      expect(page.seo_title).to be_nil
      expect(page.seo_description).to be_nil
      expect(page.canonical).to be_nil
      expect(page.cover).to be_nil
      expect(page.recommended).to eq([])
    end
    it 'converts empty strings to nil for specific attributes' do
      data = valid_data.merge({
                                'seo_title' => '',
                                'seo_description' => '',
                                'canonical' => '',
                                'cover' => ''
                              })
      page = Page.new(data)
      expect(page.seo_title).to be_nil
      expect(page.seo_description).to be_nil
      expect(page.canonical).to be_nil
      expect(page.cover).to be_nil
    end
  end

  describe '.create' do
    context 'when API call is successful' do
      it 'returns a Page object' do
        page = Page.create(NullJsonAPI.new(nil, <<~JSON
          {
            "lang": "en",
            "seo_title": "Test Title",
            "seo_description": "Test Description",
            "canonical": "https://example.com",
            "cover": "https://example.com/cover.jpg",
            "recommended": []
          }
        JSON
        ))
        expect(page).to be_a(Page)
        expect(page.lang).to eq('en')
      end
    end

    context 'when API call fails' do
      it 'returns a Page object with nil values' do
        page = Page.create(NullJsonAPI.new(nil))
        expect(page).to be_a(Page)
        expect(page.lang).to be_nil
        expect(page.seo_title).to be_nil
        expect(page.seo_description).to be_nil
        expect(page.canonical).to be_nil
        expect(page.cover).to be_nil
        expect(page.recommended).to eq([])
      end
    end
  end

  describe '.load_from_keventer with caching' do
    before do
      CacheService.clear
      Page.api_client = nil
    end

    let(:page_data) do
      {
        'lang' => 'es',
        'seo_title' => 'Test Page',
        'seo_description' => 'Test Description',
        'recommended' => []
      }
    end

    it 'caches API responses to avoid repeated calls' do
      call_count = 0
      
      # Mock JsonAPI to track calls
      allow(JsonAPI).to receive(:new) do |url|
        call_count += 1
        NullJsonAPI.new(nil, page_data.to_json)
      end
      
      allow(KeventerAPI).to receive(:page_url).and_return('https://api.example.com/pages/test')

      # First call
      page1 = Page.load_from_keventer('es', 'test-slug')
      
      # Second call should use cache
      page2 = Page.load_from_keventer('es', 'test-slug')
      
      expect(call_count).to eq(1)
      expect(page1.seo_title).to eq('Test Page')
      expect(page2.seo_title).to eq('Test Page')
    end

    it 'uses different cache keys for different lang/slug combinations' do
      call_count = 0
      
      allow(JsonAPI).to receive(:new) do |url|
        call_count += 1
        NullJsonAPI.new(nil, page_data.to_json)
      end
      
      allow(KeventerAPI).to receive(:page_url).and_return('https://api.example.com/pages/test')

      Page.load_from_keventer('es', 'test-slug')
      Page.load_from_keventer('en', 'test-slug')
      Page.load_from_keventer('es', 'other-slug')
      
      expect(call_count).to eq(3)
    end

    it 'handles cache expiration correctly' do
      call_count = 0
      
      allow(JsonAPI).to receive(:new) do |url|
        call_count += 1
        NullJsonAPI.new(nil, page_data.to_json)
      end
      
      allow(KeventerAPI).to receive(:page_url).and_return('https://api.example.com/pages/test')

      # First call
      Page.load_from_keventer('es', 'test-slug')
      
      # Manually clear cache using the correct cache key format
      url = 'https://api.example.com/pages/test'
      cache_key = "page_es_test-slug_#{url}"
      CacheService.delete(cache_key)
      
      # Second call should hit API again
      Page.load_from_keventer('es', 'test-slug')
      
      expect(call_count).to eq(2)
    end

    it 'handles nil slug in cache key' do
      call_count = 0
      
      allow(JsonAPI).to receive(:new) do |url|
        call_count += 1
        NullJsonAPI.new(nil, page_data.to_json)
      end
      
      allow(KeventerAPI).to receive(:page_url).and_return('https://api.example.com/pages/home')

      page = Page.load_from_keventer('es', nil)
      
      expect(page).to be_a(Page)
      expect(page.seo_title).to eq('Test Page')
      expect(call_count).to eq(1)
    end
  end
end
