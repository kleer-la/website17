require 'date'
require './lib/services/api_accessible'
require './lib/services/keventer_api'
require './lib/services/cache_service'

class ParticipantRegistration
  include APIAccessible

  attr_reader :event_id

  def initialize(event_id)
    @event_id = event_id
  end

  def load_event_data(lang = 'es')
    if defined?(self.class.api_client) && self.class.api_client
      json_api = self.class.api_client
    else
      url = KeventerAPI.event_url(@event_id, { lang: lang })
      cache_key = "participant_registration_event_#{@event_id}_#{lang}_#{url}"

      json_api = CacheService.get_or_set(cache_key) do
        JsonAPI.new(url)
      end
    end

    if json_api&.ok?
      data = json_api.doc
      # eventer's event JSON exposes only the raw registration_ends/date, not a
      # registration_ended boolean. Derive it here (same rule as eventer's
      # Event#registration_ended?) so the form can be hidden for closed events.
      data['registration_ended'] = registration_ended?(data) if data.is_a?(Hash)
      { success: true, data: data }
    else
      { success: false, error: :not_found, status: 404 }
    end
  rescue StandardError => e
    if ENV['RACK_ENV'] == 'development'
      raise e
    else
      puts "Event API Error: #{e.message}" unless ENV['RACK_ENV'] == 'test'
      { success: false, error: :service_unavailable, status: 503 }
    end
  end

  def load_pricing_data(quantity)
    if defined?(self.class.api_client) && self.class.api_client
      json_api = self.class.api_client
    else
      url = KeventerAPI.participant_pricing_url(@event_id, quantity)
      cache_key = "participant_registration_pricing_#{@event_id}_#{quantity}_#{url}"

      json_api = CacheService.get_or_set(cache_key) do
        JsonAPI.new(url)
      end
    end

    if json_api&.ok?
      { success: true, data: json_api.doc }
    else
      { success: false, error: :pricing_unavailable, status: 503 }
    end
  rescue StandardError => e
    if ENV['RACK_ENV'] == 'development'
      raise e
    else
      puts "Pricing API Error: #{e.message}"
      { success: false, error: :service_unavailable, status: 503 }
    end
  end

  def submit_registration(params)
    if defined?(self.class.api_client) && self.class.api_client
      json_api = self.class.api_client
      if json_api.ok?
        {
          success: true,
          body: json_api.doc.to_json,
          status: 200
        }
      else
        # When API client is set but fails, treat as service unavailable (for testing unreachable scenarios)
        {
          success: false,
          body: { error: "Registration service temporarily unavailable", details: "API unreachable" }.to_json,
          status: 503
        }
      end
    else
      url = KeventerAPI.participant_register_url(@event_id)

      begin
        response = HTTParty.post(url, {
          body: params.to_h,
          headers: { 'Accept' => 'application/json' }
        })

        if response.success?
          {
            success: true,
            body: response.body,
            status: response.code
          }
        else
          {
            success: false,
            body: response.body,
            status: response.code
          }
        end
      rescue Errno::ECONNREFUSED, Net::TimeoutError, SocketError, HTTParty::Error => e
        {
          success: false,
          body: { error: "Registration service temporarily unavailable", details: e.message }.to_json,
          status: 503
        }
      rescue StandardError => e
        {
          success: false,
          body: { error: "Registration failed due to unexpected error", details: e.message }.to_json,
          status: 500
        }
      end
    end
  end

  # Mirrors eventer's Event#registration_ended?: registration is closed once the
  # earlier of the event date / registration_ends deadline is before today.
  def registration_ended?(event, today = Date.today)
    dates = [event['date'], event['registration_ends']].compact.filter_map do |d|
      Date.parse(d.to_s)
    rescue ArgumentError, TypeError
      nil
    end
    return false if dates.empty?

    dates.min < today
  end

  class << self
    attr_accessor :api_client

    def null_json_api(null_api)
      @api_client = null_api
    end

    # Alias for testing compatibility
    alias_method :api_client=, :null_json_api
  end
end