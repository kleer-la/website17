require 'spec_helper'
require './lib/services/keventer_api'

RSpec.describe KeventerAPI do
  subject { KeventerAPI }
  before do
    subject.config[:base_url] = 'https://test.example.com'
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
      articles: 'articles.json',
      mailer: 'contact_us'
    }.each do |method, path|
      it "generates correct URL for ##{method}_url" do
        expect(subject.send("#{method}_url")).to eq("https://test.example.com/api/#{path}")
      end
    end
    # it { expect(subject.mailer_url).to eq('https://test.example.com/api/contact_us') }
  end

  describe 'Parameterized URL methods' do
    {
      service_area: ['test-slug', 'service_areas/test-slug.json'],
      event_type: [123, 'event_types/123.json'],
      article: ['test-article', 'articles/test-article.json']
    }.each do |method, (param, expected_path)|
      it "generates correct URL for ##{method}_url" do
        expect(KeventerAPI.send("#{method}_url", param)).to eq("https://test.example.com/api/#{expected_path}")
      end
    end
  end

  describe 'Participant registration URL methods' do
    it 'generates correct URL for participant_register_url' do
      expect(KeventerAPI.participant_register_url(123)).to eq('https://test.example.com/api/v3/events/123/participants/register')
    end

    it 'generates correct URL for participant_pricing_url' do
      expect(KeventerAPI.participant_pricing_url(123, 2)).to eq('https://test.example.com/api/v3/events/123/participants/pricing_info?quantity=2')
    end
  end
end
