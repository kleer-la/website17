require './lib/json_api'
require './lib/keventer_connection/mailer'

KEVENTER_URL = ENV['KEVENTER_URL'] || 'https://eventos.kleer.la'
API_ROOT = KEVENTER_URL + '/api'.freeze
API_EVENTS_PATH = '/events'.freeze
API_KLEERERS_PATH = '/kleerers'.freeze
API_CATEGORIES_PATH = '/categories.xml'.freeze
API_RESOURCES_PATH = '/resources.json'.freeze

API_MAILER = '/contact_us'.freeze

def echo(value)
  puts "----- #{caller[1][/`([^']*)'/, 1]}   #{value} -------" if ENV['RACK_ENV'] == 'test'
  value
end

class KeventerConnector
  def initialize(response = nil)
    @response = response
  end

  def events_json_url
    echo API_ROOT + API_EVENTS_PATH + '.json'
  end
  def self.resources_url
    echo KEVENTER_URL + API_RESOURCES_PATH
  end

  def kleerers_xml_url
    echo API_ROOT + API_KLEERERS_PATH + '.xml'
  end

  def self.kleerers_json_url
    echo API_ROOT + API_KLEERERS_PATH + '.json'
  end

  def categories_xml_url
    echo API_ROOT + API_CATEGORIES_PATH
  end
  def self.categories_json_url
    echo API_ROOT + '/categories.json'.freeze
  end
  def self.catalog_url
    echo API_ROOT + '/catalog'
  end
  def self.news_url
    echo API_ROOT + '/news.json'.freeze
  end

  def event_type_url(event_type_id, format = :xml)
    echo API_ROOT + "/event_types/#{event_type_id}.#{format}".freeze
  end

  def keventer_url
    echo KEVENTER_URL
  end

  def self.interest_url
    echo API_ROOT + '/v3/participants/interest'.freeze
  end

  def self.articles_url
    echo KEVENTER_URL + '/articles.json'.freeze
  end

  def self.article_url(slug)
    echo KEVENTER_URL + "/articles/#{slug}.json"
  end

  def get_catalog
    return JSON.parse(@response) unless @response.nil?
    JsonAPI.new(echo API_ROOT + '/catalog')
  end

  def get_testimonies(id)
    return JSON.parse(@response) unless @response.nil?
    JsonAPI.new("#{API_ROOT}/event_types/#{id}/testimonies.json")
  end

  def send_mail(data)
    return JSON.parse(@response) unless @response.nil?
    Mailer.new("#{API_ROOT}#{API_MAILER}",data)
  end
end
