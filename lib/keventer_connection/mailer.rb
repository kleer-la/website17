require 'faraday'
require 'uri'

class Mailer

  def initialize(url, data)
    @response = Faraday.post(url) do |req|
      req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
      req.body = URI.encode_www_form(data)
    end
  end
end
