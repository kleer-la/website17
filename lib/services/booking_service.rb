require 'faraday'
require 'json'

class BookingService
  def initialize(consultant_id, data)
    data[:secret] = ENV['CONTACT_US_SECRET']

    url = KeventerAPI.consultant_booking_url(consultant_id)
    @response = Faraday.post(url) do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = data.to_json
    end
  end

  def success?
    @response.status == 201
  end

  def parsed_body
    @parsed_body ||= begin
      JSON.parse(@response.body) if @response.body
    rescue JSON::ParserError => e
      puts "Failed to parse booking response: #{e.message}"
      {}
    end
  end

  def booking_id
    parsed_body['id']
  end

  def status
    parsed_body['status']
  end

  def google_meet_link
    parsed_body['google_meet_link']
  end

  def consultant_name
    parsed_body['consultant_name']
  end

  def starts_at
    parsed_body['starts_at']
  end

  def ends_at
    parsed_body['ends_at']
  end
end
