require 'spec_helper'
require './lib/site_crawl'

describe SiteCrawl do
  let(:crawl) { described_class.new('https://qa.kleer.la') }
  let(:source) { 'https://qa.kleer.la/es/recursos' }

  describe '#internal' do
    it 'makes a relative href absolute' do
      expect(crawl.internal('/es/somos', source)).to eq 'https://qa.kleer.la/es/somos'
    end

    it 'keeps an absolute href on the same host' do
      expect(crawl.internal('https://qa.kleer.la/es/somos', source)).to eq 'https://qa.kleer.la/es/somos'
    end

    it 'drops the fragment, which is the same page' do
      expect(crawl.internal('/es/somos#equipo', source)).to eq 'https://qa.kleer.la/es/somos'
    end

    it 'ignores another host' do
      expect(crawl.internal('https://academia.kleer.la/p/x', source)).to be_nil
    end

    it 'ignores what is not a page' do
      expect(crawl.internal('mailto:hola@kleer.la', source)).to be_nil
      expect(crawl.internal('tel:+5491100000000', source)).to be_nil
      expect(crawl.internal('#top', source)).to be_nil
    end

    it 'ignores static files, which are the slow half of a crawl' do
      expect(crawl.internal('/img/logo.png', source)).to be_nil
      expect(crawl.internal('/css/index.css', source)).to be_nil
      expect(crawl.internal('/brochure.PDF', source)).to be_nil
    end

    it 'keeps the sitemap, which is a list of URLs to check' do
      expect(crawl.internal('/sitemap.xml', source)).to eq 'https://qa.kleer.la/sitemap.xml'
    end
  end

  describe '#references_in' do
    it 'reads links, canonical and alternates, each under its own kind' do
      body = <<~HTML
        <html><head>
          <link rel="canonical" href="https://qa.kleer.la/es/recursos"/>
          <link rel="alternate" hreflang="en" href="/en/resources"/>
        </head><body>
          <a href="/es/somos">Somos</a>
          <a href="https://linkedin.com/x">LinkedIn</a>
        </body></html>
      HTML

      refs = crawl.references_in(source, body, 'text/html')

      expect(refs.map(&:kind)).to contain_exactly(:link, :canonical, :alternate)
      expect(refs.map(&:target)).to include 'https://qa.kleer.la/en/resources'
    end

    it 'reads a sitemap as a list of targets' do
      body = '<urlset><url><loc>https://qa.kleer.la/es/blog</loc></url></urlset>'

      refs = crawl.references_in(source, body, 'application/xml')

      expect(refs.map(&:kind)).to eq [:sitemap]
      expect(refs.first.target).to eq 'https://qa.kleer.la/es/blog'
    end
  end
end
