require 'date'

require './lib/keventer_connector'
require './lib/keventer_event'
require './lib/keventer_event_type'
class Catalog
  def self.catalog_events()
    events = []
    begin
      loaded_events = KeventerConnector.new.get_catalog&.get_response
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
    rescue StandardError => e
      puts "Error al cargar el catalogo: #{e}"
    end

    events
  end
end
