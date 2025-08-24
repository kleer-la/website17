require_relative '../../spec_helper'
require './lib/models/recommended'

RSpec.describe Recommended do
  describe '#cover' do
    let(:article_data) do
      {
        'type' => 'article',
        'title' => 'Test Article',
        'subtitle' => 'Test subtitle',
        'slug' => 'test-article',
        'cover' => 'https://kleer-images.s3.sa-east-1.amazonaws.com/test-cover.jpg'
      }
    end

    it 'replaces S3 URLs with CDN URLs in recommended articles' do
      recommended = Recommended.create(article_data)
      
      expect(recommended.cover).to eq('https://d3vnsn21cv5bcd.cloudfront.net/test-cover.jpg')
    end

    it 'handles empty cover URLs' do
      article_data['cover'] = ''
      recommended = Recommended.create(article_data)
      
      expect(recommended.cover).to eq('')
    end

    it 'handles nil cover URLs' do
      article_data['cover'] = nil
      recommended = Recommended.create(article_data)
      
      expect(recommended.cover).to be_nil
    end

    it 'preserves existing CDN URLs' do
      article_data['cover'] = 'https://d3vnsn21cv5bcd.cloudfront.net/already-cdn.jpg'
      recommended = Recommended.create(article_data)
      
      expect(recommended.cover).to eq('https://d3vnsn21cv5bcd.cloudfront.net/already-cdn.jpg')
    end
  end
end