require './lib/timezone_converter'

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
    @capacity = 0
    @city = @place = @country = @country_code = ''
    @event_type = nil
    @date = @finish_date = @start_time = @end_time = nil
    @is_sold_out = false
    @sepyme_enabled = false
    @id = 0
    @trainers = []
    @keventer_connector = nil
    @registration_link = @human_date = @address = ''

    init_prices
    @time_zone_name = ''
    @time_zone = nil

    @specific_conditions = ''
    @specific_subtitle = ''
    @banner_text = ''
    @banner_type = ''
    @is_community_event = false
    @mode = ''

    @enable_online_payment = false
    @online_course_codename = ''
    @online_cohort_codename = ''
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

  def is_online
    mode == 'ol'
  end

  def is_classroom
    mode == 'cl'
  end

  def is_blended_learning
    mode == 'bl'
  end

  def discount
    if @eb_price.nil? || @eb_price < 0.01 || @list_price.nil? || @list_price < 0.01
      0.0
    else
      @list_price - @eb_price
    end
  end

  def uri_path
    uri_path_to_return = @id.to_s
    uri_event_type_name = @event_type.name.downcase
    uri_path_to_return += "-#{uri_event_type_name.gsub(/ /, '-')}"
    uri_city = @city.downcase
    uri_path_to_return += "-#{uri_city.gsub(/ /, '-')}"
    uri_path_to_return
  end

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
    load_date(event_doc)
    load_details(event_doc)
    load_status(event_doc)
    load_price(event_doc)
  end

  def load_descripcion(event_doc)
    @id = event_doc.find_first('id').content.to_i
    @capacity = event_doc.find_first('capacity').content.to_i
    @city = event_doc.find_first('city').content
    @place = event_doc.find_first('place').content
    @address = event_doc.find_first('address').content
    @registration_link = event_doc.find_first('registration-link').content

    @enable_online_payment = to_boolean(event_doc.find_first('enable-online-payment').content)
    @online_course_codename = event_doc.find_first('online-course-codename').content
    @online_cohort_codename = event_doc.find_first('online-cohort-codename').content

    @country = event_doc.find_first('country/name').content
    @country_code = event_doc.find_first('country/iso-code').content
    @currency_iso_code = event_doc.find_first('currency-iso-code').content
  end

  def load_date(event_doc)
    @date = Date.parse(event_doc.find_first('date').content)
    @finish_date = validated_Date_parse(event_doc.find_first('finish-date'))
    @start_time = DateTime.parse(event_doc.find_first('start-time').content)
    @end_time = DateTime.parse(event_doc.find_first('end-time').content)
  end

  def load_details(event_doc)
    @specific_subtitle = event_doc.find_first('specific-subtitle').content
    @specific_conditions = event_doc.find_first('specific-conditions').content
    @is_community_event = event_doc.find_first('visibility-type').content == 'co'
    @mode = event_doc.find_first('mode').content
    @banner_text = event_doc.find_first('banner-text').content
    @banner_type = event_doc.find_first('banner-type').content
  end

  def load_status(event_doc)
    @is_sold_out = to_boolean(event_doc.find_first('is-sold-out').content)
  end

  def load_price(event_doc)
    @show_pricing = to_boolean(event_doc.find_first('show-pricing').content)
    @list_price = event_doc.find_first('list-price').content.nil? ? 0.0 : event_doc.find_first('list-price').content.to_f
    @eb_price = event_doc.find_first('eb-price').content.nil? ? 0.0 : event_doc.find_first('eb-price').content.to_f
    @eb_end_date = validated_Date_parse(event_doc.find_first('eb-end-date')) if @eb_price > 0.0
    @couples_eb_price = event_doc.find_first('couples-eb-price').content.nil? ? 0.0 : event_doc.find_first('couples-eb-price').content.to_f
    @business_eb_price = event_doc.find_first('business-eb-price').content.nil? ? 0.0 : event_doc.find_first('business-eb-price').content.to_f
    @business_price = event_doc.find_first('business-price').content.nil? ? 0.0 : event_doc.find_first('business-price').content.to_f
    @enterprise_6plus_price = event_doc.find_first('enterprise-6plus-price').content.nil? ? 0.0 : event_doc.find_first('enterprise-6plus-price').content.to_f
    @enterprise_11plus_price = event_doc.find_first('enterprise-11plus-price').content.nil? ? 0.0 : event_doc.find_first('enterprise-11plus-price').content.to_f
  end

  def timezone_url
    duration = end_time.to_time - start_time.to_time
    hours = (duration / 3600).to_i
    minutes = ((duration % 3600) / 60).to_i

    "https://www.timeanddate.com/worldclock/fixedtime.html?#{
      URI.encode_www_form(
        msg: @event_type.name,
        iso: "#{date.strftime('%Y%m%d')}T#{start_time.strftime('%H%M')}",
        p1: TimezoneConverter.timezone(place),
        ah: hours,
        am: minutes
      )
    }"
  end
end
