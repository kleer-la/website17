require './lib/services/api_accessible'
require './lib/services/keventer_api'
require './lib/models/recommended'

class Page
  include APIAccessible

  api_connector KeventerAPI

  attr_accessor :lang, :seo_title, :seo_description, :canonical, :recommended

  def initialize(data)
    @lang = data['lang']
    @seo_title = data['seo_title']
    @seo_description = data['seo_description']
    @canonical = data['canonical']
    init_recommended(data)
  end

  def self.load_from_json(file_path)
    data = JSON.parse(File.read(file_path))
    new(data)
  end

  def self.load_from_keventer(lang, slug)
    url = KeventerAPI.page_url(lang, slug)
    json_api = JsonAPI.new(url)
    new(json_api.doc) if json_api.ok?
  end

  def init_recommended(doc)
    @recommended = Recommended.create_list(doc['recommended'])
  end
end
