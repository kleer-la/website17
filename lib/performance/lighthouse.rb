require 'fileutils'
require 'open3'
require './lib/performance/lighthouse_report'

module Performance
  # Runs the Lighthouse installed in the devcontainer image (tools/lighthouse)
  # against a URL, with its default mobile emulation, and keeps the JSON and
  # HTML reports in tmp/perf.
  module Lighthouse
    BIN = ENV.fetch('LIGHTHOUSE_BIN', '/opt/lighthouse/node_modules/.bin/lighthouse')
    CHROME = ENV.fetch('CHROME_PATH', '/usr/bin/chromium')
    OUT = 'tmp/perf'.freeze

    def self.run(url, name)
      FileUtils.mkdir_p(OUT)
      path = File.join(OUT, name)
      _out, err, status = Open3.capture3(
        { 'CHROME_PATH' => CHROME },
        BIN, url, '--quiet', '--only-categories=performance',
        '--chrome-flags=--headless=new --no-sandbox --disable-dev-shm-usage',
        '--output=json', '--output=html', "--output-path=#{path}"
      )
      raise "Lighthouse failed on #{url}: #{err.lines.last(5).join}" unless status.success?

      LighthouseReport.from_file("#{path}.report.json")
    end
  end
end
