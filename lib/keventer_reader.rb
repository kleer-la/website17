require 'libxml'
require 'date'
require 'tzinfo'

require './lib/keventer_helper'
require './lib/keventer_event'
require './lib/keventer_event_type'
require './lib/country'
require './lib/keventer_connector'
require './lib/professional'
require './lib/category'

#TODO: REVISAR ARQUITECTURA - READER? - NULL INFRASCTRUCTURE?

def event_from_parsed_xml(xml_keventer_event)
  event = KeventerEvent.new
  event.load xml_keventer_event
  event
end

class KeventerReader
  attr_accessor :connector

  def self.build
    @instance = KeventerReader.new(KeventerConnector.new)
  end

  def self.build_with(connector)
    @instance = KeventerReader.new(connector)
  end

  class << self
    attr_reader :instance
  end

  def initialize(connector = nil)
    @connector = connector || KeventerConnector.new
    @events_hash_dont_use_directly = {}
  end

  def events
    load_remote_events
  end

  def coming_commercial_events(from = Date.today, months = 2)
    coming_events(@connector.events_xml_url, from, months)
  end

  def commercial_events_by_country(country_iso_code)
    events_by_country(@connector.events_xml_url, country_iso_code)
  end

  def event(event_id, force_read = false)
    load_remote_event(event_id, force_read)
  end

  def event_type(event_type_id, force_read = false)
    event_type = load_remote_event_type(event_type_id, force_read)
    event_type.public_editions = load_remote_event_type_editions(event_type_id, force_read) unless event_type.nil?
    event_type
  end

  def unique_countries_for_commercial_events
    unique_countries(@connector.events_xml_url)
  end

  # TODO: check error when getting API resource
  def parse(file, node)
    parser = LibXML::XML::Parser.file(file)
    doc = parser.parse
    doc.find(node)
  end

  def kleerers(lang = 'es')
    begin
      loaded_kleerers = parse @connector.kleerers_xml_url, '/trainers/trainer'
      kleerers = loaded_kleerers.reduce([]) { |ac, one_kleerer| ac << Professional.new(one_kleerer, lang) }
    rescue StandardError => e
      puts "Error al cargar kleerers: #{e}"
      kleerers = []
    end

    kleerers
  end

  def category(code_name, lang = 'es')
    all = categories lang
    all.select { |category| category.codename == code_name }.first
  end

  def catalog_events()
    events = []
    begin
      loaded_events = @connector.get_catalog&.get_response
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

  def categories(lang = 'es')
    categories = []

    begin
      loaded_categories = parse @connector.categories_xml_url, '/categories/category'

      loaded_categories.each do |loaded_category|
        category = Category.new loaded_category, lang

        category.event_types = load_event_types(loaded_category)
        categories << category
      end

      categories.sort! { |p, q| p.order <=> q.order }
    rescue StandardError => e
      puts "Error al cargar las categorías: #{e}"
      categories = []
    end

    categories
  end

  private

  def load_event_types(event_types_xml_node)
    event_types = []
    event_types_xml_node&.find('event-types/event-type')&.each do |event_type_node|
      event_type = create_event_type(event_type_node)
      event_types << event_type if event_type.include_in_catalog
    end
    event_types
  end

  def coming_events(event_type_xml_url, from = Date.today, months = 2)
    coming_events = []

    load_remote_events(event_type_xml_url).each do |event|
      coming_events << event if event.date <= (from >> months)
    end

    coming_events
  end

  def events_by_country(event_type_xml_url, country_iso_code)
    events_by_country = []

    # FIXME
    # esto es feo, tenemos que resolver de otra manera la situacion
    # en la cual el usuario no encuentra cursos.
    return events_by_country if country_iso_code == 'otro'

    load_remote_events(event_type_xml_url).each do |event|
      next unless (country_iso_code == 'todos') ||
                  (event.country_code.downcase == 'ol') ||
                  (event.country_code.downcase == country_iso_code)

      events_by_country << event
    end

    events_by_country
  end

  def unique_countries(event_type_xml_url)
    countries = []
    online_country = nil

    load_remote_events(event_type_xml_url).each do |event|
      if event.country_code.downcase == 'ol'
        online_country = Country.new('ol', 'Online')
      else
        country = Country.new(event.country_code.downcase, event.country)
        countries << country unless countries.include?(country)
      end
    end

    countries.sort! { |x, y| x.name <=> y.name }

    # Despues de que esta ordenado agrego Online al final
    countries << online_country unless online_country.nil?

    countries
  end

  def load_remote_events(event_type_xml_url = @connector.events_xml_url, force_read = true)
    if remote_events_still_valid(event_type_xml_url, force_read)
      return @events_hash_dont_use_directly[event_type_xml_url]
    end

    loaded_events = parse event_type_xml_url, '/events/event'
    events = []
    loaded_events.each do |loaded_event|
      events << create_event(loaded_event)
    end

    @events_hash_dont_use_directly[event_type_xml_url] = events
  end

  def load_remote_event(event_id, force_read = false)
    event = nil

    event_id = event_id.to_i

    load_remote_events(@connector.events_xml_url, force_read).each do |event_found|
      event = event_found if event_found.id == event_id
    end

    event
  end

  def load_remote_event_type(event_type_id, _force_read = false)
    event_type_id = event_type_id.to_i

    begin
      url = @connector.event_type_url(event_type_id)
      parser = LibXML::XML::Parser.file(url)
      doc = parser.parse
      create_event_type(doc)
    rescue LibXML::XML::Error => e
      puts(e)
    end
  end

  def load_remote_event_type_editions(event_type_id, force_read)
    all_events = load_remote_events(@connector.events_xml_url, force_read)

    public_editions = []

    all_events.each do |event|
      public_editions << event if event.event_type.id == event_type_id.to_i
    end

    public_editions
  end

  def create_one_trainer(xml)
    trainer = Professional.new
    trainer.name = first_content(xml, 'name')
    trainer.bio = first_content(xml, 'bio')
    trainer.id = first_content(xml, 'id')
    trainer.linkedin_url = first_content(xml, 'linkedin-url')
    trainer.gravatar_picture_url = first_content(xml, 'gravatar-picture-url')
    trainer.twitter_username = first_content(xml, 'twitter-username')

    trainer.surveyed_count = first_content(xml, 'surveyed-count').to_i
    trainer
  end

  def create_event(xml_keventer_event)
    event = event_from_parsed_xml(xml_keventer_event)

    xml_trainers = xml_keventer_event.find('./trainers/trainer')

    xml_trainers.each do |t|
      event.add_trainer create_one_trainer(t)
    end

    event.event_type = create_event_type(xml_keventer_event.find_first('event-type'))

    event.keventer_connector = @connector

    event
  end

  def create_event_type(xml_keventer_event)
    event_type = KeventerEventType.new
    event_type.load xml_keventer_event
    event_type
  end

  def remote_events_still_valid(event_type_xml_url, force_read)
    !(@events_hash_dont_use_directly[event_type_xml_url].nil? || force_read)
  end
end
