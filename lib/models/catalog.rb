require 'date'

require './lib/keventer_connector'
require './lib/keventer_event'
require './lib/keventer_event_type'
class Catalog
  def self.load_catalog_events(loaded_events)
    events = []
    begin
      loaded_events.each do |loaded_event|
        event_type = EventType.new(nil, loaded_event)
        event = Event.new(event_type)
        event.country_iso = loaded_event['country_iso']
        event.country_name = loaded_event['country_name']

        unless loaded_event['date'].nil?
          #TODO: migrate to Event method
          event.load_from_json(loaded_event)
        end

        events.push(event)
      end
    rescue
      puts "Error al cargar el catalogo"
    end

    events
  end

  class << self
    def create_keventer_json(lang)
      if defined? @@json_api
        json_api = @@json_api
      else
        json_api = JsonAPI.new(KeventerConnector.catalog_url)
      end
      Catalog.load_catalog_events(json_api.doc) unless json_api.doc.nil?
    end

    def null_json_api(null_api)
      puts "Ha entrado la api nula"
      @@json_api = null_api
    end
  end
end
