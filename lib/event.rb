require './lib/timezone_converter'
require './lib/keventer_helper'
require './lib/trainer'

class Event
  attr_accessor :country_iso, :country_name, :certified,
                :city, :country, :country_code, :event_type, :date,
                :finish_date, :registration_link, :is_sold_out, :id, :eb_date,                                             #TODO remove duplicate fields
                :list_price, :eb_price, :eb_end_date, :currency_iso_code,
                :show_pricing,
                :place, :address,
                :start_time, :end_time, :time_zone_name, :time_zone,
                :is_sold_out,
                :specific_conditions,
                :mode, :banner_text, :banner_type, :specific_subtitle, :enable_online_payment

                #:capacity, :sepyme_enabled, :human_date, :is_community_event,
                #:couples_eb_price, :business_eb_price,
                #:business_price, :enterprise_6plus_price, :enterprise_11plus_price,
                #:online_course_codename, :online_cohort_codename
  attr_reader :trainers

  def initialize(event_type)
    @event_type = event_type
    @country_iso = 'OL'
    @id = 0
    @capacity = 0
    @city = @place = @country = @country_code = @address = ''
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
    @trainers = load_trainers(ev_json['trainers'])
    self
  end

  def load_basic(hash_event)
    @id = hash_event['id'] ? hash_event['id'].to_i : hash_event['event_id']
    load_str(%i[city place address registration_link time_zone_name is_sold_out], hash_event)

    # @id = first_content(event_doc, 'id').to_i
    # @capacity = first_content(event_doc, 'capacity').to_i
    # @city = first_content(event_doc, 'city')
    # @place = first_content(event_doc, 'place')
    # @address = first_content(event_doc, 'address')
    # @registration_link = first_content(event_doc, 'registration-link')

    # @enable_online_payment = to_boolean(first_content(event_doc, 'enable-online-payment'))
    # @online_course_codename = first_content(event_doc, 'online-course-codename')
    # @online_cohort_codename = first_content(event_doc, 'online-cohort-codename')
  end

  def load_date(hash_event)
    %i[date finish_date   ].each { |field| send("#{field}=", Date.parse(    hash_event[field.to_s])) }
    %i[start_time end_time].each { |field| send("#{field}=", DateTime.parse(hash_event[field.to_s])) }
  end

  def load_details(hash_event)
    %i[mode banner_text banner_type specific_subtitle specific_conditions
    ].each { |field| send("#{field}=", hash_event[field.to_s]) }

    # @specific_subtitle = first_content(event_doc, 'specific-subtitle')
    # @specific_conditions = first_content(event_doc, 'specific-conditions')
    # @is_community_event = first_content(event_doc, 'visibility-type') == 'co'
    # @mode = first_content(event_doc, 'mode')
    # @banner_text = first_content(event_doc, 'banner-text')
    # @banner_type = first_content(event_doc, 'banner-type')
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
    %i[list_price eb_price
    ].each { |field| send("#{field}=", hash_event[field.to_s]) }

    @eb_end_date = hash_event['eb_end_date'] ? Date.parse(hash_event['eb_end_date']) : nil
    @eb_date = hash_event['eb_end_date']

    # @show_pricing = to_boolean(first_content(event_doc, 'show-pricing'))
    # @list_price = first_content_f(event_doc, 'list-price')
    # @eb_price = first_content_f(event_doc, 'eb-price')
    # @eb_end_date = validated_date_parse(event_doc.find_first('eb-end-date')) if @eb_price > 0.0
    # @couples_eb_price = first_content_f(event_doc, 'couples-eb-price')
    # @business_eb_price = first_content_f(event_doc, 'business-eb-price')
    # @business_price = first_content_f(event_doc, 'business-price')
    # @enterprise_6plus_price = first_content_f(event_doc, 'enterprise-6plus-price')
    # @enterprise_11plus_price = first_content_f(event_doc, 'enterprise-11plus-price')
  end

  def load_trainers(hash_trainers)
    return [] if hash_trainers.nil?

    hash_trainers.reduce([]) do |trainers, t_json|
      trainers << Trainer.new.load_from_json(t_json)
    end
  end

  def timezone_url
    duration = @end_time.to_time - @start_time.to_time
    hours = (duration / 3600).to_i
    minutes = ((duration % 3600) / 60).to_i

    "https://www.timeanddate.com/worldclock/fixedtime.html?#{URI.encode_www_form(
      msg: @event_type.name,
      iso: "#{date.strftime('%Y%m%d')}T#{start_time.strftime('%H%M')}",
      p1: TimezoneConverter.timezone(@time_zone_name),
      ah: hours,
      am: minutes
    ) }"
  end

end


class EventFacade
  attr_reader :name, :subtitle, :cover,
              :certified, :slug, :categories,
              :date,:finish_date, :country_iso, :country_name, :city

  def initialize()
    @name = @subtitle= @cover =
    @certified= @slug= @categories =
    @date= @country_iso = @country_name = @city = nil
  end

  def from_event_type(et)
    @name = et.name
    @subtitle = et.subtitle
    @cover = et.cover
    @certified= (2 if et.is_sa_cert).to_i +
                (1 if et.is_kleer_cert).to_i
    @slug = et.slug
    @categories = et.categories
    self
  end
  def from_event(e)
    @date = e.date
    @country_iso = e.country_iso
    @country_name = e.country_name
    from_event_type(e.event_type)
  end

end
