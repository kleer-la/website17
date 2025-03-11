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
end
