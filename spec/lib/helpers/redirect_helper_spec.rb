require 'spec_helper'
require './lib/helpers/redirect_helper'

describe RedirectHelper do
  include RedirectHelper

  describe '#unify_domains' do
    # robots.txt is a file of the host, not of a page: by specification it lives
    # at the root and governs everything crawled there. Prefixing it sent
    # kleer.la/robots.txt to /es/robots.txt — which resolves, but puts the file
    # that decides what gets crawled behind the language rewrite.
    context 'with a file that belongs to the host, not to a language' do
      %w[/robots.txt /sitemap.xml /.well-known/security.txt].each do |path|
        it "keeps #{path} at the root" do
          target_url, = unify_domains('kleer.la', path)
          expect(target_url).to eq("https://www.kleer.la#{path}")
        end
      end

      it 'does it for the English host too' do
        target_url, = unify_domains('kleer.us', '/robots.txt')
        expect(target_url).to eq('https://www.kleer.la/robots.txt')
      end

      it 'still prefixes an ordinary path' do
        target_url, = unify_domains('kleer.la', '/recursos')
        expect(target_url).to eq('https://www.kleer.la/es/recursos')
      end
    end

    context 'when host is a redirect domain' do
      it 'redirects kleer.us to www.kleer.la/en/' do
        target_url, locale = unify_domains('kleer.us', '/')
        expect(target_url).to eq('https://www.kleer.la/en/')
        expect(locale).to eq('en')
      end

      it 'redirects kleer.es to www.kleer.la/es/' do
        target_url, locale = unify_domains('kleer.es', '/')
        expect(target_url).to eq('https://www.kleer.la/es/')
        expect(locale).to eq('es')
      end

      it 'redirects www.kleer.us to www.kleer.la/en/' do
        target_url, locale = unify_domains('www.kleer.us', '/')
        expect(target_url).to eq('https://www.kleer.la/en/')
        expect(locale).to eq('en')
      end

      it 'redirects kleer.la to www.kleer.la/es/' do
        target_url, locale = unify_domains('kleer.la', '/')
        expect(target_url).to eq('https://www.kleer.la/es/')
        expect(locale).to eq('es')
      end

      it 'preserves path and adds locale prefix' do
        target_url, locale = unify_domains('kleer.us', '/about')
        expect(target_url).to eq('https://www.kleer.la/en/about')
        expect(locale).to eq('en')
      end

      it 'does not add locale prefix if path already has /en' do
        target_url, locale = unify_domains('kleer.us', '/en/about')
        expect(target_url).to eq('https://www.kleer.la/en/about')
        expect(locale).to eq('en')
      end

      it 'does not add locale prefix if path already has /es' do
        target_url, locale = unify_domains('kleer.es', '/es/about')
        expect(target_url).to eq('https://www.kleer.la/es/about')
        expect(locale).to eq('es')
      end

      it 'returns nil target_url if on www.kleer.la with correct locale path' do
        target_url, locale = unify_domains('www.kleer.la', '/en/about')
        expect(target_url).to be_nil
        expect(locale).to eq('en')
      end
    end

    context 'when host is not a redirect domain' do
      it 'returns nil target_url and locale for www.kleer.la' do
        target_url, locale = unify_domains('www.kleer.la', '/about')
        expect(target_url).to be_nil
        expect(locale).to eq('es') # Since not kleer.us
      end

      it 'returns nil target_url and locale for other domains' do
        target_url, locale = unify_domains('example.com', '/')
        expect(target_url).to be_nil
        expect(locale).to eq('es')
      end
    end
  end
end
