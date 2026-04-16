require 'openssl'
require 'base64'
require 'json'
require 'rack/utils'

module BookingToken
  TTL = 30 * 60 # 30 minutes

  module_function

  def secret
    ENV.fetch('CONTACT_US_SECRET') { raise 'CONTACT_US_SECRET not set' }
  end

  def generate(email:, area_slug:, name: '')
    payload = { email: email, name: name, area_slug: area_slug, timestamp: Time.now.to_i }.to_json
    signature = OpenSSL::HMAC.digest('SHA256', secret, payload)
    Base64.urlsafe_encode64(signature + payload)
  end

  def valid?(token, area_slug:)
    return false if token.nil? || token.empty?

    decoded = Base64.urlsafe_decode64(token)
    signature = decoded[0, 32]
    payload_json = decoded[32..]

    expected_signature = OpenSSL::HMAC.digest('SHA256', secret, payload_json)
    return false unless Rack::Utils.secure_compare(signature, expected_signature)

    payload = JSON.parse(payload_json)
    return false unless payload['area_slug'] == area_slug
    return false if Time.now.to_i - payload['timestamp'] > TTL

    payload
  rescue StandardError
    false
  end
end
