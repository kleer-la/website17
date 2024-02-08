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



  def create_event_type(xml_keventer_event)
    event_type = KeventerEventType.new
    event_type.load xml_keventer_event
    event_type
  end

  def remote_events_still_valid(event_type_xml_url, force_read)
    !(@events_hash_dont_use_directly[event_type_xml_url].nil? || force_read)
  end
end
