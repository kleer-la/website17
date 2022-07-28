require './lib/json_api'

KEVENTER_URL = ENV['KEVENTER_URL'] || 'http://eventos.kleer.la'
API_ROOT = KEVENTER_URL + '/api'.freeze
API_EVENTS_PATH = '/events.xml'.freeze
API_KLEERERS_PATH = '/kleerers.xml'.freeze
API_CATEGORIES_PATH = '/categories.xml'.freeze
class KeventerConnector
  def initialize(response = nil)
    @response = response
  end

  def events_xml_url
    API_ROOT + API_EVENTS_PATH
  end

  def kleerers_xml_url
    API_ROOT + API_KLEERERS_PATH
  end

  def categories_xml_url
    API_ROOT + API_CATEGORIES_PATH
  end

  def event_type_url(event_type_id)
    API_ROOT + "/event_types/#{event_type_id}.xml".freeze
  end

  def keventer_url
    KEVENTER_URL
  end

  def self.interest_url
    API_ROOT + '/v3/participants/interest'.freeze
  end

  def self.articles_url
    KEVENTER_URL + '/articles.json'.freeze
  end

  def self.article_url(slug)
    KEVENTER_URL + "/articles/#{slug}.json"
  end

  def get_catalog
    return JSON.parse(@response) unless @response.nil?
    JsonAPI.new(API_ROOT + '/catalog')
  end
end
