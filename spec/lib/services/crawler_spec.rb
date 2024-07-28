require 'spec_helper'
require './lib/services/crawler' # adjust the path as necessary

RSpec.describe Crawler do
  let(:base_url) { 'https://www.kleer.la' }
  let(:crawler) { Crawler.new(base_url) }

  before do
    allow(crawler).to receive(:get).and_return(double('response', status: 200, body: ''))
  end

  describe '#execute' do
    it 'crawls the start path' do
      expect(crawler).to receive(:get).with('/').once
      crawler.execute
    end

    it 'returns an empty array when no errors are found' do
      expect(crawler.execute).to eq([])
    end

    context 'when encountering links' do
      before do
        allow(crawler).to receive(:get).and_return(
          double('response', status: 200, body: <<-HTML
            <a href="/page1">Page 1</a>
            <a href="/page2">Page 2</a>
            <a href="http://external.com">External</a>
          HTML
          )
        )
      end

      it 'crawls internal links' do
        expect(crawler).to receive(:get).with('/').once
        expect(crawler).to receive(:get).with('/page1').once
        expect(crawler).to receive(:get).with('/page2').once
        crawler.execute
      end

      it 'does not crawl external links' do
        expect(crawler).not_to receive(:get).with('http://external.com')
        crawler.execute
      end
    end

    context 'when encountering errors' do
      before do
        allow(crawler).to receive(:get).with('/').and_return(double('response', status: 200,
                                                                                body: '<a href="/error">Error</a>'))
        allow(crawler).to receive(:get).with('/error').and_return(double('response', status: 404, body: ''))
      end

      it 'records 404 errors' do
        errors = crawler.execute
        expect(errors).to include(hash_including(url: 'https://www.kleer.la/error', error: 'HTTP 404'))
      end
    end
  end
  context 'when encountering cyclic links' do
    before do
      allow(crawler).to receive(:get).with('/').and_return(
        double('response', status: 200, body: '<a href="/page1">Page 1</a>')
      )
      allow(crawler).to receive(:get).with('/page1').and_return(
        double('response', status: 200, body: '<a href="/">Home</a>')
      )
    end

    it 'does not crawl the same URL twice' do
      expect(crawler).to receive(:get).with('/').once
      expect(crawler).to receive(:get).with('/page1').once
      crawler.execute
    end
  end

  context 'when encountering errors' do
    before do
      allow(crawler).to receive(:get).with('/').and_return(
        double('response', status: 200, body: '<a href="/error">Error</a><a href="/page">Page</a>')
      )
      allow(crawler).to receive(:get).with('/error').and_return(double('response', status: 404, body: ''))
      allow(crawler).to receive(:get).with('/page').and_return(
        double('response', status: 200, body: '<a href="/another-error">Another Error</a>')
      )
      allow(crawler).to receive(:get).with('/another-error').and_return(double('response', status: 500, body: ''))
    end

    it 'records errors with the URL of the containing page' do
      errors = crawler.execute
      expect(errors).to include(
        hash_including(url: 'https://www.kleer.la/error', error: 'HTTP 404', parent_url: 'https://www.kleer.la/')
      )
      expect(errors).to include(
        hash_including(url: 'https://www.kleer.la/another-error', error: 'HTTP 500', parent_url: 'https://www.kleer.la/page')
      )
    end
  end

  context 'when an exception occurs during crawling' do
    before do
      allow(crawler).to receive(:get).with('/').and_return(
        double('response', status: 200, body: '<a href="/error">Error</a>')
      )
      allow(crawler).to receive(:get).with('/error').and_raise(StandardError.new('Network error'))
    end

    it 'records the exception with the URL of the containing page' do
      errors = crawler.execute
      expect(errors).to include(
        hash_including(url: 'https://www.kleer.la/error', error: 'Network error', parent_url: 'https://www.kleer.la/')
      )
    end
  end
  context 'when determining internal vs external links' do
    it 'correctly identifies internal links' do
      internal_urls = [
        'https://www.kleer.la/page1',
        'https://kleer.la/page2',
        '/relative/path',
        '/',
        'https://www.kleer.la'
      ]

      internal_urls.each do |url|
        internal = crawler.internal_url?(url)
        expect(internal).to be(true), "Expected #{url} to be internal"
      end
    end

    it 'correctly identifies external links' do
      external_urls = [
        'http://external.com',
        'https://www.google.com',
        'ftp://files.example.com'
      ]

      external_urls.each do |url|
        expect(crawler.internal_url?(url)).to be(false), "Expected #{url} to be external"
      end
    end
  end
end
