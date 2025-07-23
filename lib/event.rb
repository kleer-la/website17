require './lib/timezone_converter'
require './lib/keventer_helper'
require './lib/trainer'
require './lib/json_api'
require './lib/services/cache_service'
require './lib/services/api_accessible'

class Event
  include APIAccessible
  api_connector(Class.new { def url_for(id) = KeventerAPI.events_url })

  attr_accessor :country_iso, :country_name, :certified,
                :city, :country, :country_code, :event_type, :date,
                :finish_date, :registration_link, :is_sold_out, :id, :eb_date, # TODO: remove duplicate fields
                :list_price, :eb_price, :eb_end_date, :currency_iso_code,
                :show_pricing,
                :place, :address,
                :start_time, :end_time, :time_zone_name, :time_zone,
                :is_sold_out,
                :specific_conditions, :duration,
                :mode, :banner_text, :banner_type, :specific_subtitle

  # ,:enable_online_payment
  # :capacity, :sepyme_enabled, :human_date, :is_community_event,
  # :couples_eb_price, :business_eb_price,
  # :business_price, :enterprise_6plus_price, :enterprise_11plus_price,
  # :online_course_codename, :online_cohort_codename
  attr_reader :trainers

  def initialize(event_type)
    @event_type = event_type
    @country_iso = 'OL'
    @id = 0
    @capacity = 0
    @city = @place = @country = @country_code = @address = @registration_link = ''
    @trainers = []

    # init_prices
    # init_datetime
    # init_flags
    # init_registration
  end

  def load_from_json(ev_json)
    load_basic(ev_json)
    load_date(ev_json)
    load_details(ev_json)
    load_price(ev_json)
    load_country(ev_json['country'])
    @trainers = load_trainers(ev_json['trainers'])
    self
  end

  def load_basic(hash_event)
    @id = hash_event['id'] ? hash_event['id'].to_i : hash_event['event_id']
    load_str(%i[city place address registration_link time_zone_name is_sold_out], hash_event)
  end

  def load_date(hash_event)
    hash_event['finish_date'] = hash_event['date'] if hash_event['finish_date'].to_s.empty?
    %i[date finish_date].each { |field| send("#{field}=", Date.parse(hash_event[field.to_s])) }
    %i[start_time end_time].each { |field| send("#{field}=", DateTime.parse(hash_event[field.to_s])) }
    @duration = hash_event['duration'].to_i
  end

  def load_details(hash_event)
    load_str(%i[mode banner_text banner_type specific_subtitle specific_conditions], hash_event)
  end

  def online?
    @mode == 'ol'
  end

  def blended_learning?
    mode == 'bl'
  end

  def load_str(syms, hash)
    syms.each { |field| send("#{field}=", hash[field.to_s]) }
  end

  def load_price(hash_event)
    @show_pricing = to_boolean(hash_event['show_pricing'])
    %i[list_price eb_price currency_iso_code].each { |field| send("#{field}=", hash_event[field.to_s]) }

    @eb_end_date = hash_event['eb_end_date'] ? Date.parse(hash_event['eb_end_date']) : nil
    @eb_date = hash_event['eb_end_date']
  end

  def load_country(hash)
    return if hash.nil?

    @country_name = hash['name'].to_s
    @country_iso = hash['iso_code'].to_s
  end

  def load_trainers(hash_trainers)
    return [] if hash_trainers.nil?

    hash_trainers.reduce([]) do |trainers, t_json|
      trainers << Trainer.new.load_from_json(t_json)
    end
  end

  def timezone_url
    hour_dif = @end_time.to_time - @start_time.to_time
    hours = (hour_dif / 3600).to_i
    minutes = ((hour_dif % 3600) / 60).to_i

    "https://www.timeanddate.com/worldclock/fixedtime.html?#{URI.encode_www_form(
      msg: @event_type.name,
      iso: "#{date.strftime('%Y%m%d')}T#{start_time.strftime('%H%M')}",
      p1: TimezoneConverter.timezone(@time_zone_name),
      ah: hours,
      am: minutes
    ) }"
  end

  def registration_ended?(current_date = Date.today)
    date.nil? || date <= current_date
  end

  class << self
    def create_keventer_json(today = Date.today, cache_key: nil)
      cache_key ||= "home_events_#{I18n.locale || 'es'}" # Match new_home cache key
      CacheService.get_or_set(cache_key) do
        json_api = if defined? @@json_api
                     @@json_api
                   else
                     JsonAPI.new(KeventerAPI.events_url)
                   end
        load_events(json_api.doc, today) unless json_api.doc.nil?
      end || [] # Ensure array is returned even if cache returns nil
    rescue StandardError => e
      if ENV['RACK_ENV'] == 'development'
        raise e # Re-raise the original error with full context
      else
        puts "Event API Error: #{e.message}" # Log error for debugging
        [] # Return empty array in production
      end
    end

    def null_json_api(null_api)
      @@json_api = null_api
    end

    def load_events(events, today)
      Array(events).reduce([]) do |ac, ev|
        event_type_json = ev['event_type']
        event_type_json['coupons'] = ev['coupons']
        event_type = EventType.new(event_type_json)
        e = Event.new(event_type).load_from_json(ev)
        if e.registration_ended?(today)
          ac
        else
          ac << e
        end
      end
    end
  end
end
