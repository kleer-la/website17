class SiteCrawl
  # The HTTP half, kept apart so the walking logic can be read — and stubbed —
  # without a network.
  class Fetcher
    # Some hosts answer HEAD with a refusal and the page itself with 200.
    RETRY_WITH_GET = [403, 405, 501].freeze

    def initialize(timeout: 20, user_agent: 'kleer-site-crawl')
      @timeout = timeout
      @user_agent = user_agent
      @checked = {}
    end

    # The status of a URL and where it sends us, without downloading the body.
    def status(url)
      @checked[url] ||= begin
        response = connection.head(url)
        response = connection.get(url) if RETRY_WITH_GET.include?(response.status)
        [response.status, response.headers['location']]
      rescue StandardError => e
        [e.class.name, nil]
      end
    end

    # The body of a page worth reading references from, or nil.
    def page(url)
      response = connection.get(url)
      content_type = response.headers['content-type']
      return [nil, nil] unless response.status == 200 && content_type.to_s.match?(/html|xml/)

      [response.body, content_type]
    rescue StandardError
      [nil, nil]
    end

    def connection
      @connection ||= Faraday.new do |f|
        f.options.timeout = @timeout
        f.headers['User-Agent'] = @user_agent
      end
    end
  end
end
