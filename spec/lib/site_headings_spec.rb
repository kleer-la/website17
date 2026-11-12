require 'spec_helper'
require './lib/site_headings'

# The heading outline of the published pages, not of templates with fixtures:
# Keventer content changes without a deploy (#466).
describe SiteHeadings do
  # Answers like SiteCrawl::Fetcher, from a hash of URL => body or [status, location].
  let(:fetcher) do
    pages = site
    Class.new do
      define_method(:page) do |url|
        body = pages[url]
        next [nil, nil] unless body.is_a?(String)

        [body, url.end_with?('.xml') ? 'application/xml' : 'text/html']
      end
      define_method(:status) do |url|
        answer = pages[url]
        next answer if answer.is_a?(Array)

        [answer ? 200 : 404, nil]
      end
    end.new
  end

  def sitemap(*paths)
    "<urlset>#{paths.map { "<url><loc>https://www.kleer.la#{_1}</loc></url>" }.join}</urlset>"
  end

  let(:sound) { '<h1>Kleer</h1><section><h2>Servicios</h2><h3>Producto</h3></section>' }
  let(:skipping) { '<h1>Un artículo</h1><h3>Tabla de contenido</h3>' }

  let(:site) do
    { 'https://qa.kleer.la/sitemap.xml' => sitemap('/es/', '/es/blog/uno', '/es/blog/dos', '/es/recursos/tres'),
      'https://qa.kleer.la/es/' => sound,
      'https://qa.kleer.la/es/blog/uno' => [301, '/es/blog/uno/'],
      'https://qa.kleer.la/es/blog/uno/' => skipping,
      'https://qa.kleer.la/es/blog/dos' => skipping,
      'https://qa.kleer.la/es/recursos/tres' => sound }
  end

  let(:check) { described_class.new('https://qa.kleer.la', fetcher: fetcher).run }

  it 'checks the pages of the sitemap on the site it is given, following redirects' do
    expect(check.checked).to eq 4
    expect(check.pages.keys).to eq ['https://qa.kleer.la/es/blog/uno/', 'https://qa.kleer.la/es/blog/dos']
    expect(check.pages.values.flatten.map(&:rule).uniq).to eq [:skipped_level]
  end

  it 'reports a page it could not read' do
    site.delete('https://qa.kleer.la/es/blog/dos')

    expect(check.unreadable).to eq ['https://qa.kleer.la/es/blog/dos']
  end

  it 'summarises by section before listing each page' do
    report = check.report

    expect(report).to include('4 pages checked, 2 with heading problems')
    expect(report).to match(%r{/es/blog\s+2 pages\s+2 problems})
    expect(report).not_to include('/es/recursos ')
    expect(report).to include("https://qa.kleer.la/es/blog/dos\n  h3 «Tabla de contenido» comes right after h1")
  end

  it 'reads the body as UTF-8' do
    site['https://qa.kleer.la/es/blog/dos'] = (+'<h1>Diseño</h1><h3>Índice</h3>').force_encoding('ASCII-8BIT')

    expect(check.report).to include('h3 «Índice» comes right after h1 «Diseño»')
  end
end
