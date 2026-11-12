require 'json'
require 'uri'

module Performance
  # What one Lighthouse run (its JSON output) says about a page: the requests
  # made while it loaded and the timings. The performance specs check rules on
  # the requests, which are stable from run to run, and only report the
  # timings, which are not.
  class LighthouseReport
    Request = Struct.new(:url, :type, :bytes) do
      def host
        URI(url).host
      rescue URI::InvalidURIError
        nil
      end

      def kb
        (bytes / 1024.0).round
      end
    end

    METRICS = {
      fcp: 'first-contentful-paint',
      lcp: 'largest-contentful-paint',
      tbt: 'total-blocking-time',
      cls: 'cumulative-layout-shift'
    }.freeze

    def self.from_file(path)
      new(JSON.parse(File.read(path)))
    end

    def initialize(json)
      @json = json
    end

    def url
      @json['finalDisplayedUrl'] || @json['finalUrl'] || @json['requestedUrl']
    end

    def host
      URI(url).host
    end

    def score
      (@json.dig('categories', 'performance', 'score').to_f * 100).round
    end

    # Milliseconds, except CLS, which has no unit.
    def metric(name)
      @json.dig('audits', METRICS.fetch(name), 'numericValue')
    end

    def requests
      items('network-requests').map { Request.new(_1['url'], _1['resourceType'], _1['transferSize'].to_i) }
    end

    def requests_of(type)
      requests.select { _1.type == type }
    end

    def bytes_of(type)
      requests_of(type).sum(&:bytes)
    end

    def own_requests
      requests.select { _1.host == host }
    end

    def render_blocking
      items('render-blocking-resources').map { _1['url'] }
    end

    def uncompressed
      items('uses-text-compression').map { _1['url'] }
    end

    private

    def items(audit)
      @json.dig('audits', audit, 'details', 'items') || []
    end
  end
end
