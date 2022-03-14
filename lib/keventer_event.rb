require './lib/timezone_converter'
require './lib/keventer_helper'

class KeventerEvent
  attr_accessor :capacity, :city, :country, :country_code, :event_type, :date,
                :finish_date, :registration_link, :is_sold_out, :id,
                :keventer_connector, :place, :sepyme_enabled,
                :human_date, :start_time, :end_time, :address, :list_price,
                :eb_price, :eb_end_date, :currency_iso_code,
                :specific_conditions, :is_community_event, :time_zone_name,
                :time_zone, :show_pricing, :couples_eb_price, :business_eb_price,
                :business_price, :enterprise_6plus_price, :enterprise_11plus_price,
                :mode, :banner_text, :banner_type, :specific_subtitle, :enable_online_payment,
                :online_course_codename, :online_cohort_codename
  attr_reader :trainers

  def initialize
    @id = 0
    @capacity = 0
    @city = @place = @country = @country_code = @address = ''
    @event_type = nil
    @trainers = []
    @keventer_connector = nil

    init_prices
    init_datetime
    init_flags
    init_registration
  end

  def init_registration
    @registration_link = ''
    @specific_conditions = @specific_subtitle = ''
    @banner_text = @banner_type = ''

    @enable_online_payment = false
    @online_course_codename = ''
    @online_cohort_codename = ''
  end

  def init_flags
    @is_sold_out = false
    @sepyme_enabled = false
    @is_community_event = false
    @mode = ''
  end

  def init_prices
    @show_pricing = false
    @list_price = 0.0
    @eb_price = 0.0
    @eb_end_date = nil
    @couples_eb_price = 0.0
    @business_eb_price = 0.0
    @business_price = 0.0
    @enterprise_6plus_price = 0.0
    @enterprise_11plus_price = 0.0
    @currency_iso_code = ''
  end

  def init_datetime
    @date = @finish_date = @start_time = @end_time = nil
    @human_date = @time_zone_name = ''
    @time_zone = nil
  end

  def online?
    mode == 'ol'
  end

  def classroom?
    mode == 'cl'
  end

  def blended_learning?
    mode == 'bl'
  end

  def discount
    if @eb_price.nil? || @eb_price < 0.01 || @list_price.nil? || @list_price < 0.01
      0.0
    else
      @list_price - @eb_price
    end
  end

  # def uri_path #TODO depecated
  #   uri_path_to_return = @id.to_s
  #   uri_event_type_name = @event_type.name.downcase
  #   uri_path_to_return += "-#{uri_event_type_name.gsub(/ /, '-')}"
  #   uri_city = @city.downcase
  #   uri_path_to_return += "-#{uri_city.gsub(/ /, '-')}"
  #   uri_path_to_return
  # end

  def friendly_title
    "#{@event_type.name} - #{@city}"
  end

  def to_s
    @id
  end

  def add_trainer(trainer)
    @trainers <<= trainer unless trainer.nil?
  end

  def load(event_doc)
    load_descripcion(event_doc)
    load_country(event_doc)
    load_date(event_doc)
    load_details(event_doc)
    load_status(event_doc)
    load_price(event_doc)
  end

  def load_descripcion(event_doc)
    @id = first_content(event_doc, 'id').to_i
    @capacity = first_content(event_doc, 'capacity').to_i
    @city = first_content(event_doc, 'city')
    @place = first_content(event_doc, 'place')
    @address = first_content(event_doc, 'address')
    @registration_link = first_content(event_doc, 'registration-link')

    @enable_online_payment = to_boolean(first_content(event_doc, 'enable-online-payment'))
    @online_course_codename = first_content(event_doc, 'online-course-codename')
    @online_cohort_codename = first_content(event_doc, 'online-cohort-codename')
  end

  def load_country(event_doc)
    @country = first_content(event_doc, 'country/name')
    @country_code = first_content(event_doc, 'country/iso-code')
    @currency_iso_code = first_content(event_doc, 'currency-iso-code')
  end

  def load_date(event_doc)
    @date = Date.parse(first_content(event_doc, 'date'))
    @finish_date = validated_date_parse(event_doc.find_first('finish-date'))
    @start_time = DateTime.parse(first_content(event_doc, 'start-time'))
    @end_time = DateTime.parse(first_content(event_doc, 'end-time'))
  end

  def load_details(event_doc)
    @specific_subtitle = first_content(event_doc, 'specific-subtitle')
    @specific_conditions = first_content(event_doc, 'specific-conditions')
    @is_community_event = first_content(event_doc, 'visibility-type') == 'co'
    @mode = first_content(event_doc, 'mode')
    @banner_text = first_content(event_doc, 'banner-text')
    @banner_type = first_content(event_doc, 'banner-type')
  end

  def load_status(event_doc)
    @is_sold_out = to_boolean(first_content(event_doc, 'is-sold-out'))
  end

  def load_price(event_doc)
    @show_pricing = to_boolean(first_content(event_doc, 'show-pricing'))
    @list_price = first_content_f(event_doc, 'list-price')
    @eb_price = first_content_f(event_doc, 'eb-price')
    @eb_end_date = validated_date_parse(event_doc.find_first('eb-end-date')) if @eb_price > 0.0
    @couples_eb_price = first_content_f(event_doc, 'couples-eb-price')
    @business_eb_price = first_content_f(event_doc, 'business-eb-price')
    @business_price = first_content_f(event_doc, 'business-price')
    @enterprise_6plus_price = first_content_f(event_doc, 'enterprise-6plus-price')
    @enterprise_11plus_price = first_content_f(event_doc, 'enterprise-11plus-price')
  end

  def timezone_url
    duration = end_time.to_time - start_time.to_time
    hours = (duration / 3600).to_i
    minutes = ((duration % 3600) / 60).to_i

    "https://www.timeanddate.com/worldclock/fixedtime.html?#{URI.encode_www_form(
      msg: @event_type.name,
      iso: "#{date.strftime('%Y%m%d')}T#{start_time.strftime('%H%M')}",
      p1: TimezoneConverter.timezone(place),
      ah: hours,
      am: minutes
    ) }"
  end
end
