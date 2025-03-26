require 'faraday'
require 'uri'

class Mailer
  def initialize(url, data)
    data[:secret] = ENV['CONTACT_US_SECRET']

    @response = Faraday.post(url) do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = data.to_json
    end
  end
  def parsed_body
    @parsed_body ||= JSON.parse(@response.body)
  end

  # Specific getters for id, status, and assessment_report_url
  def id
    parsed_body['data']['id']
  end

  def status
    parsed_body['data']['status']
  end

  def assessment_report_url
    parsed_body['data']['assessment_report_url']
  end
end
