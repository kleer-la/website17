require 'spec_helper'
require './lib/performance/lighthouse_report'

describe Performance::LighthouseReport do
  def request(url, type, bytes)
    { 'url' => url, 'resourceType' => type, 'transferSize' => bytes }
  end

  let(:report) do
    described_class.new(
      'finalDisplayedUrl' => 'https://qa.kleer.la/es/',
      'categories' => { 'performance' => { 'score' => 0.37 } },
      'audits' => {
        'first-contentful-paint' => { 'numericValue' => 3612.4 },
        'largest-contentful-paint' => { 'numericValue' => 10_840.0 },
        'network-requests' => { 'details' => { 'items' => [
          request('https://qa.kleer.la/es/', 'Document', 45_000),
          request('https://qa.kleer.la/app/css/site.css?v=1', 'Stylesheet', 27_000),
          request('https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css', 'Stylesheet', 24_000),
          request('https://www.googletagmanager.com/gtm.js?id=X', 'Script', 170_000),
          request('https://qa.kleer.la/app/img/hero.webp', 'Image', 90_000)
        ] } },
        'render-blocking-resources' => { 'details' => { 'items' => [{ 'url' => 'https://qa.kleer.la/app/css/site.css?v=1' }] } }
      }
    )
  end

  it 'reads the score and the timings' do
    expect(report.score).to eq 37
    expect(report.metric(:fcp)).to eq 3612.4
    expect(report.metric(:lcp)).to eq 10_840.0
  end

  it 'lists the requests by type' do
    expect(report.requests_of('Stylesheet').map(&:url))
      .to eq ['https://qa.kleer.la/app/css/site.css?v=1',
              'https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css']
    expect(report.bytes_of('Script')).to eq 170_000
  end

  it 'tells our requests from third parties' do
    expect(report.own_requests.map(&:type)).to eq %w[Document Stylesheet Image]
  end

  it 'lists render-blocking resources' do
    expect(report.render_blocking).to eq ['https://qa.kleer.la/app/css/site.css?v=1']
  end

  it 'reads an audit Lighthouse left out as empty' do
    expect(report.uncompressed).to be_empty
  end
end
