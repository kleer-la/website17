require './lib/json_api'
require './lib/keventer_connection/mailer'

KEVENTER_URL = ENV['KEVENTER_URL'] || 'http://eventos.kleer.la'
API_ROOT = KEVENTER_URL + '/api'.freeze
API_EVENTS_PATH = '/events'.freeze
API_KLEERERS_PATH = '/kleerers.xml'.freeze
API_CATEGORIES_PATH = '/categories.xml'.freeze

API_MAILER = '/contact_us'.freeze
class KeventerConnector
  def initialize(response = nil)
    @response = response
  end

  def events_xml_url(format = :xml)
    API_ROOT + API_EVENTS_PATH + ".#{format}"
  end

  def kleerers_xml_url
    API_ROOT + API_KLEERERS_PATH
  end

  def categories_xml_url
    API_ROOT + API_CATEGORIES_PATH
  end
  def self.categories_json_url
    API_ROOT + '/categories.json'.freeze
  end

  def event_type_url(event_type_id, format = :xml)
    API_ROOT + "/event_types/#{event_type_id}.#{format}".freeze
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

  def get_testimonies(id)
    return JSON.parse(@response) unless @response.nil?
    JsonAPI.new("#{API_ROOT}/event_types/#{id}/testimonies.json")
  end

  def send_mail(data)
    Mailer.new("#{API_ROOT}#{API_MAILER}",data)
  end
end
