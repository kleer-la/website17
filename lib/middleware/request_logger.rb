require 'json'

module Middleware
  class RequestLogger
    STATIC_EXT = /\.(css|js|png|jpg|jpeg|gif|ico|svg|webp|woff2?|ttf|eot|map)$/i

    def initialize(app)
      @app = app
    end

    def call(env)
      return @app.call(env) if static_asset?(env['PATH_INFO'])

      start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      status, headers, body = @app.call(env)
      duration_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000).round(1)

      log_entry = {
        timestamp: Time.now.utc.iso8601,
        method: env['REQUEST_METHOD'],
        path: env['PATH_INFO'],
        query: env['QUERY_STRING'].to_s.empty? ? nil : env['QUERY_STRING'],
        status: status,
        duration_ms: duration_ms,
        ip: env['HTTP_X_FORWARDED_FOR'] || env['REMOTE_ADDR'],
        user_agent: env['HTTP_USER_AGENT'],
        referer: env['HTTP_REFERER'],
        host: env['HTTP_HOST']
      }.compact

      log_entry[:level] = status >= 500 ? 'error' : (status >= 400 ? 'warn' : 'info')

      $stdout.puts(JSON.generate(log_entry))

      [status, headers, body]
    end

    private

    def static_asset?(path)
      path.match?(STATIC_EXT)
    end
  end
end
