class Resource
  @next_null = false

  def self.create_list_null(data)
    @next_null = true
    @objects_null = Resource.load_list(data)
  end

  def self.create_list_keventer()
    if @next_null
      @next_null = false
      return @objects_null
    end
    api_resp = JsonAPI.new(KeventerAPI.resources_url)
    raise :NotFound unless api_resp.ok?

    Resource.load_list(api_resp.doc)
  end

  attr_accessor :id, :format, :slug, :lang, :authors, :translators, :authors_list, :translators_list, :illustrators_list,
                :fb_share, :tw_share, :li_share, :share_link, :kleer_share_url,
                :title, :description, :cover, :landing, :getit, :buyit, :share_link, :share_text, :tags, :comments

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
    @buyit = doc["buyit_#{lang}"] || ''
    @share_link = doc["share_link_#{lang}"] || ''
    @share_text = doc["share_text_#{lang}"] || ''
    @tags = doc["tags_#{lang}"] || ''
    @comments = doc["comments_#{lang}"] || ''

    #insert lang
    @kleer_share_url = "https://www.kleer.la/#{lang}/recursos##{@slug}"

    share_url = @kleer_share_url
    share_url = @share_link unless @share_link.to_s == ''


    @fb_share = URI.encode_www_form(
      u: share_url,
      quote: @share_text,
      hashtags: @tags
    )

    @tw_share = URI.encode_www_form(
      text: "#{@share_text} #{share_url}",
      hashtags: @tags
    )
    # https://www.linkedin.com/sharing/share-offsite/?url=[your URL]&summary=[your post text]&source=[your source]&hashtags=[your hashtags separated by commas]

    @li_share = URI.encode_www_form(
      url: share_url,
      summary: "#{@share_text} #{share_url}",
      source: @kleer_share_url,
      hashtags: @tags
    )

    @authors = init_trainers(doc, 'authors')
    @authors_list = doc['authors'].map{|e| e['name']}

    @translators = init_trainers(doc, 'translators')
    @translators_list = doc['translators'].map{|e| e['name']}
    @illustrators_list = doc['illustrators'].map{|e| e['name']}

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
    return nil if doc[role].nil?
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
