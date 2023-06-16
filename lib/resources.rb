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

  attr_accessor :id, :format, :slug, :lang, :authors, :translators, :authors_list, :translators_list,
                :fb_share, :tw_share, :li_share, :share_link, :kleer_share_url,
                :title, :description, :cover, :landing, :getit, :share_link, :share_text, :tags, :comments

  def initialize(doc, lang)
    @id = doc['id']
    @format = doc['format']
    @slug = doc['slug']
    @lang = lang

    @title = doc["title_#{lang}"]
    @description = doc["description_#{lang}"]
    @cover = doc["cover_#{lang}"] || ''
    @landing = doc["landing_#{lang}"] || ''
    @getit = doc["getit_#{lang}"] || ''
    @share_link = doc["share_link_#{lang}"] || ''
    @share_text = doc["share_text_#{lang}"] || ''
    @tags = doc["tags_#{lang}"] || ''
    @comments = doc["comments_#{lang}"] || ''

    @kleer_share_url = "https://kleer.la/#{locale}/recursos##{resource.slug}"


    @fb_share = URI.encode_www_form(
      u: @share_link,
      quote: resource.share_text,
      hashtags: resource.tags
    )

    @tw_share = URI.encode_www_form(
      text: "#{resource.share_text} #{@share_link}",
      hashtags: resource.tags
    )
    # https://www.linkedin.com/sharing/share-offsite/?url=[your URL]&summary=[your post text]&source=[your source]&hashtags=[your hashtags separated by commas]

    @li_share = URI.encode_www_form(
      url: @share_link,
      summary: "#{resource.share_text} #{@share_link}",
      source: @kleer_share_url,
      hashtags: resource.tags
    )

    @authors = init_trainers(doc, 'authors')
    @authors_list = doc['authors'].map{|e| e['name']}

    @translators = init_trainers(doc, 'translators')
    @translators_list = doc['translators'].map{|e| e['name']}

    init_dates(doc)
    # "categories_id": null,
    # "trainers_id": null,
  end
  def show_one_trainer(trainer_data)
    trainer = trainer_data['name']
    landing = trainer_data['landing']
    trainer = "<a href=\"#{landing}\">#{trainer}</a>" unless landing.to_s == ''
    trainer
  end
  def init_trainers(doc, role)
    list = (doc[role]&.reduce([]) { |ac, t| ac << show_one_trainer(t) }
                )
    unless list == []
      list.join(', ')
    else
      nil
    end
  end
  def init_dates(doc)
    @created_at = doc['created_at'] || ''
    @updated_at = doc['updated_at'] || ''
  end
  def self.load_list(doc)
    doc.each_with_object([]) {|data, ac|
      (ac << Resource.new(data, :es) ) unless data['title_es'] == ''
      (ac << Resource.new(data, :en) ) unless data['title_en'] == ''
      ac
    }
  end
end
