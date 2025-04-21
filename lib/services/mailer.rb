require 'faraday'
require 'json'

class Mailer
  def initialize(url, data)
    data[:secret] = ENV['CONTACT_US_SECRET']

    @response = Faraday.post(url) do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = data.to_json
    end
  end

  def parsed_body
    @parsed_body ||= begin
      JSON.parse(@response.body) if @response.body
    rescue JSON::ParserError => e
      puts "Failed to parse response body: #{e.message}"
      {}
    end
  end

  # Specific getters for id, status, and assessment_report_url
  def id
    parsed_body['id']
  end

  def status
    parsed_body['status']
  end

  def assessment_report_url
    parsed_body['assessment_report_url']
  end
end