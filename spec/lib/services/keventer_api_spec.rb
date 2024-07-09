require 'spec_helper'
require './lib/services/keventer_api'

RSpec.describe KeventerAPI do
  before do
    KeventerAPI.config[:base_url] = 'https://test.example.com'
  end

  describe '.url_for' do
    it 'generates a correct URL with parameters' do
      expect(KeventerAPI.url_for('/test', { param: 'value' })).to eq('https://test.example.com/api/test?param=value')
    end
    it 'generates a correct URL w/o leading /' do
      expect(KeventerAPI.url_for('test', { param: 'value' })).to eq('https://test.example.com/api/test?param=value')
    end
  end

  describe 'URL methods' do
    {
      events: 'events.json',
      resources: 'resources.json',
      kleerers: 'kleerers.json',
      categories: 'categories.json',
      catalog: 'catalog',
      news: 'news.json',
      service_areas: 'service_areas.json',
      interest: 'v3/participants/interest',
      articles: 'articles.json',
      mailer: 'contact_us'
    }.each do |method, path|
      it "generates correct URL for ##{method}_url" do
        expect(KeventerAPI.send("#{method}_url")).to eq("https://test.example.com/api/#{path}")
      end
    end
  end

  describe 'Parameterized URL methods' do
    {
      service_area: ['test-slug', 'service_areas/test-slug.json'],
      event_type: [123, 'event_types/123.json'],
      article: ['test-article', 'articles/test-article.json'],
      testimonies: [456, 'event_types/456/testimonies.json']
    }.each do |method, (param, expected_path)|
      it "generates correct URL for ##{method}_url" do
        expect(KeventerAPI.send("#{method}_url", param)).to eq("https://test.example.com/api/#{expected_path}")
      end
    end
  end
end
