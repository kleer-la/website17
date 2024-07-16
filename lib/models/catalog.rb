require 'date'

class Catalog
  def self.load_catalog_events(loaded_events)
    events = []
    begin
      loaded_events.each do |loaded_event|
        unless loaded_event['percent_off'].nil?
          loaded_event['coupons'] = [{
            'icon' => loaded_event['coupon_icon'],
            'percent_off' => loaded_event['percent_off']
          }]
        end

        event_type = EventType.new(loaded_event)
        event = Event.new(event_type)

        event.load_from_json(loaded_event) unless loaded_event['date'].nil?

        events.push(event)
      end
    # TODO: review error handling
    rescue StandardError => e
      puts "Error al cargar el catalogo:#{e.message} - #{e.backtrace.grep_v(%r{/gems/}).join('\n')}"
    end

    events
  end

  class << self
    def create_keventer_json
      json_api = if defined? @@json_api
                   @@json_api
                 else
                   JsonAPI.new(KeventerAPI.catalog_url)
                 end
      Catalog.load_catalog_events(json_api.doc) unless json_api.doc.nil?
    end

    def null_json_api(null_api)
      @@json_api = null_api
    end
  end
end
