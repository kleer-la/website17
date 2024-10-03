require 'spec_helper'
require './lib/models/page'
require './lib/services/keventer_api'

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
end
