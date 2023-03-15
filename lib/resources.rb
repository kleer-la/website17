class Resources
  def initialize
    @resources = []
  end

  def all
    @resources
  end

  def load(file = File.read('./lib/resources_storage.json'))
    @resources = JSON.parse(file)['resources']
    self
  end

  def copy_lang(orig, dest)
    @resources.each { |r| r[dest] = r[orig] if r[dest].nil? }
  end
end

class Resource
  @next_null = false

  def self.create_list_null(data)
    @next_null = opt[:next_null] == true
    @objects_null = Resource.load_list(data)
  end

  def self.create_list_keventer()
    if @next_null
      @next_null = false
      return @objects_null
    end
    uri = KeventerConnector.resources_url
    api_resp = JsonAPI.new(uri)
    raise :NotFound unless api_resp.ok?

    Resource.load_list(api_resp.doc)
  end

  attr_accessor :id, :format, :slug, :lang,
                :title, :description, :cover, :landing

  def initialize(doc, lang)
    @id = doc['id']
    @format = doc['format']
    @slug = doc['slug']
    @lang = lang

    @title = doc["title_#{lang}"]
    @description = doc["description_#{lang}"]
    @cover = doc["cover_#{lang}"] || ''
    @landing = doc["landing_#{lang}"] || ''

    # "categories_id": null,
    # "trainers_id": null,
    # "share_link_es": "",
    # "share_text_es": "",
    # "tags_es": "",
    # "comments_es": "",

    # "share_link_en": "",
    # "share_text_en": "",
    # "tags_en": "",
    # "comments_en": "",
    # "created_at": "2023-03-15T21:44:17.244Z",
    # "updated_at": "2023-03-15T21:44:17.244Z",    
  end
  def self.load_list(doc)
    doc.each_with_object([]) {|data, ac| 
      (ac << Resource.new(data, :es) ) unless data['title_es'] == ''
      (ac << Resource.new(data, :en) ) unless data['title_en'] == ''
      ac
    } 
  end
end