require_relative '../spec_helper'
require './lib/articles'

RSpec.describe Article do
  describe '#cover' do
    it 'replaces S3 URLs with CDN URLs' do
      article_data = {
        'id' => 1,
        'title' => 'Test Article',
        'slug' => 'test-article',
        'cover' => 'https://kleer-images.s3.sa-east-1.amazonaws.com/test-image.jpg',
        'lang' => 'es',
        'published' => true
      }

      article = Article.new(article_data)
      
      expect(article.cover).to eq('https://d3vnsn21cv5bcd.cloudfront.net/test-image.jpg')
    end

    it 'returns empty string when cover is nil (converted to empty by initializer)' do
      article_data = {
        'id' => 1,
        'title' => 'Test Article',
        'slug' => 'test-article',
        'cover' => nil,
        'lang' => 'es',
        'published' => true
      }

      article = Article.new(article_data)
      
      expect(article.cover).to eq('')
    end

    it 'returns empty string when cover is empty' do
      article_data = {
        'id' => 1,
        'title' => 'Test Article',
        'slug' => 'test-article',
        'cover' => '',
        'lang' => 'es',
        'published' => true
      }

      article = Article.new(article_data)

      expect(article.cover).to eq('')
    end
  end

  describe '#header' do
    it 'uses header when provided' do
      article_data = {
        'id' => 1,
        'title' => 'Test Article',
        'slug' => 'test-article',
        'cover' => 'https://kleer-images.s3.sa-east-1.amazonaws.com/cover.jpg',
        'header' => 'https://kleer-images.s3.sa-east-1.amazonaws.com/header.jpg',
        'lang' => 'es',
        'published' => true
      }

      article = Article.new(article_data)

      expect(article.header).to eq('https://d3vnsn21cv5bcd.cloudfront.net/header.jpg')
    end

    it 'defaults to cover when header is nil' do
      article_data = {
        'id' => 1,
        'title' => 'Test Article',
        'slug' => 'test-article',
        'cover' => 'https://kleer-images.s3.sa-east-1.amazonaws.com/cover.jpg',
        'lang' => 'es',
        'published' => true
      }

      article = Article.new(article_data)

      expect(article.header).to eq('https://d3vnsn21cv5bcd.cloudfront.net/cover.jpg')
    end

    it 'defaults to cover when header is empty' do
      article_data = {
        'id' => 1,
        'title' => 'Test Article',
        'slug' => 'test-article',
        'cover' => 'https://kleer-images.s3.sa-east-1.amazonaws.com/cover.jpg',
        'header' => '',
        'lang' => 'es',
        'published' => true
      }

      article = Article.new(article_data)

      expect(article.header).to eq('https://d3vnsn21cv5bcd.cloudfront.net/cover.jpg')
    end
  end
end