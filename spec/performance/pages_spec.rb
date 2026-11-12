require 'spec_helper'
require './lib/performance/lighthouse'

# Lighthouse (mobile) on the pages that bring visitors, on a deployed site:
#
#   rake perf[https://qa.kleer.la]                         # rules + timings
#   rake perf[https://qa.kleer.la,https://www.kleer.la]    # timings against production too
#
# What each page requests while it loads is stable from run to run, so rules
# on it fail the spec. Timings vary by seconds between runs: they are reported
# (median of PERF_RUNS runs) and never fail. Reports: tmp/perf/*.report.html.
describe 'page performance', :perf do
  base = ENV.fetch('PERF_BASE_URL', '').chomp('/')
  baseline = ENV.fetch('PERF_BASELINE_URL', '').chomp('/')
  runs = Integer(ENV.fetch('PERF_RUNS', '3'))
  pages = %w[/es/ /es/servicios /es/servicios/producto-digital]
  # Known problems, pending until they are fixed: RSpec then fails the
  # pending example, which is the cue to drop the line.
  oversized_images = {
    '/es/' => 'website17#465: an image in Keventer content',
    '/es/servicios' => 'website17#465: an image in Keventer content'
  }
  measured = Hash.new do |cache, url|
    name = url.sub(%r{\Ahttps?://}, '').gsub(/[^a-z0-9]+/i, '-').chomp('-')
    cache[url] = Array.new(runs) { |i| Performance::Lighthouse.run(url, "#{name}-#{i + 1}") }
  end

  listed = ->(requests) { requests.sort_by { -_1.bytes }.map { "\n  #{_1.kb} KB #{_1.url[0, 100]}" }.join }

  pages.each do |path|
    describe path do
      let(:report) { measured["#{base}#{path}"].first }

      # Each form loads them when it opens (website17#465).
      it 'loads no form scripts (reCAPTCHA, Mailchimp) before a form opens' do
        expect(report.requests.map(&:url).grep(/recaptcha|mc-validate/)).to be_empty
      end

      it 'links the site styles as one stylesheet' do
        own = report.own_requests.select { _1.type == 'Stylesheet' }.map(&:url)
        expect(own.grep(%r{/app/css/site}).size).to eq(1), "site stylesheets: #{own}"
      end

      it 'blocks the first paint with at most 4 files' do
        expect(report.render_blocking.size).to be <= 4, "render-blocking:\n  #{report.render_blocking.join("\n  ")}"
      end

      # Most of it is tag manager, which loads a different set of tags from
      # run to run (730-880 KB in QA); reCAPTCHA alone added ~850 KB.
      it 'downloads at most 1 MB of JavaScript' do
        expect(report.bytes_of('Script')).to be <= 1024 * 1024, "scripts:#{listed.call(report.requests_of('Script'))}"
      end

      it 'has no image over 300 KB' do
        pending oversized_images[path] if oversized_images.key?(path)
        big = report.requests_of('Image').select { _1.bytes > 300 * 1024 }
        expect(big).to be_empty, "images:#{listed.call(big)}"
      end

      it 'serves our own files compressed' do
        own = report.uncompressed.select { URI(_1).host == report.host }
        expect(own).to be_empty
      end
    end
  end

  it 'reports the timings' do
    median = ->(values) { values.sort[values.size / 2] }
    widths = [34, 16, 6, 8, 8, 8]
    line = ->(cells) { cells.zip(widths).map { |cell, width| cell.to_s.ljust(width) }.join(' ') }
    rows = pages.flat_map do |path|
      [base, baseline].reject(&:empty?).map do |site|
        reports = measured["#{site}#{path}"]
        seconds = %i[fcp lcp tbt].map { |m| "#{(median.call(reports.map { _1.metric(m) }) / 1000.0).round(1)} s" }
        [path, URI(site).host, median.call(reports.map(&:score)), *seconds]
      end
    end
    puts "\nLighthouse, mobile, median of #{runs} runs", line.call(%w[page site score FCP LCP TBT])
    rows.each { puts line.call(_1) }
    expect(rows).not_to be_empty
  end
end
