require './lib/json_api'
require './lib/services/keventer_api'
require './lib/models/recommended'

class Page
  attr_reader :lang, :seo_title, :seo_description, :canonical, :cover, :recommended

  def initialize(data = {})
    @lang = data['lang']
    @seo_title = empty_to_nil(data['seo_title'])
    @seo_description = empty_to_nil(data['seo_description'])
    @canonical = empty_to_nil(data['canonical'])
    @cover = empty_to_nil(data['cover'])
    @recommended = Recommended.create_list(data['recommended'] || [])
  end

  class << self
    attr_accessor :api_client
  end

  def self.create(json_api)
    json_api.ok? ? new(json_api.doc) : new
  end

  def self.load_from_json(file_path)
    create(NullJsonAPI.new(file_path))
  end

  def self.load_from_keventer(lang, slug)
    url = KeventerAPI.page_url(lang, slug)
    api = @api_client || JsonAPI.new(url)
    create(api)
  end

  private

  def empty_to_nil(value)
    value.nil? || value.empty? ? nil : value
  end
end
