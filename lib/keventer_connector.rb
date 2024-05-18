require './lib/json_api'
require './lib/keventer_connection/mailer'

KEVENTER_URL = ENV['KEVENTER_URL'] || 'https://eventos.kleer.la'
API_ROOT = KEVENTER_URL + '/api'.freeze
API_EVENTS_PATH = '/events'.freeze
API_KLEERERS_PATH = '/kleerers'.freeze
API_RESOURCES_PATH = '/resources.json'.freeze
API_AREAS_PATH = '/service_areas'.freeze

API_MAILER = '/contact_us'.freeze

def echo(value)
  if ENV['RACK_ENV'] == 'test'
    caller_info = caller[1].match(/(.*):(\d+):in `([^']*)'/)
    file = caller_info[1]
    line = caller_info[2]
    method = caller_info[3]
    puts "----- #{method} (#{file}:#{line}) -->  #{value} -------"
  end
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

  def self.kleerers_json_url
    echo API_ROOT + API_KLEERERS_PATH + '.json'
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

  def self.service_areas_url
    echo API_ROOT + API_AREAS_PATH + '.json'.freeze
  end
  def self.service_area_url(slug)
    echo API_ROOT + API_AREAS_PATH + "/#{slug}.json"
  end

  def event_type_url(event_type_id)
    echo API_ROOT + "/event_types/#{event_type_id}.json".freeze
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

  def get_service_area_list
    return JSON.parse(@response) unless @response.nil?
    JsonAPI.new(echo API_ROOT + API_AREAS_PATH)
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
