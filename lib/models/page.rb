require './lib/json_api'
require './lib/services/keventer_api'
require './lib/models/recommended'
require './lib/services/cache_service'

class Page
  attr_reader :lang, :seo_title, :seo_description, :canonical, :cover, :recommended, :sections

  def initialize(data = {})
    @lang = data['lang']
    @seo_title = empty_to_nil(data['seo_title'])
    @seo_description = empty_to_nil(data['seo_description'])
    @canonical = empty_to_nil(data['canonical'])
    @cover = empty_to_nil(data['cover'])
    @recommended = Recommended.create_list(data['recommended'] || [])
    @sections = (data['sections'] || []).each_with_object({}) do |section, hash|
      hash[section['slug']] = section.slice('title', 'content', 'cta_text', 'position')
    end
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
    return create(@api_client) if @api_client
    
    url = KeventerAPI.page_url(lang, slug)
    cache_key = "page_#{lang}_#{slug}_#{url}"
    
    json_api = CacheService.get_or_set(cache_key) do
      JsonAPI.new(url)
    end
    
    create(json_api)
  end

  private

  def empty_to_nil(value)
    value.nil? || value.empty? ? nil : value
  end
end
