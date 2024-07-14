require './lib/json_api'
require './lib/services/keventer_api'
require './lib/trainer'
require './lib/models/recommended'

class Article
  @next_null = false
  @article_null = nil
  @articles_null = nil

  def self.create_one_null(art, opt = {})
    @next_null = opt[:next_null] == true
    @article_null = Article.new(art)
    @articles_null = [Article.new(art)]
  end

  def self.create_one_keventer(slug)
    if @next_null
      # @next_null = false      # bc related articles need create_one and create_list 
      return @article_null
    end
    api_resp = JsonAPI.new(KeventerAPI.article_url(slug))
    raise StandardError, "[info] Blog (#{slug}) not found" unless api_resp.ok?

    Article.new(api_resp.doc)
  end

  def self.create_list_null(arts, opt = {})
    @next_null = opt[:next_null] == true
    @articles_null = Article.load_list(arts, only_published: opt[:only_published])
  end

  def self.create_list_keventer(only_published)
    if @next_null
      @next_null = false
      return @articles_null
    end
    api_resp = JsonAPI.new(KeventerAPI.articles_url )
    raise :NotFound unless api_resp.ok?

    Article.load_list(api_resp.doc, only_published: only_published)
  end

  attr_accessor :title, :description, :tabtitle, :body, :published,
                :trainers, :trainers_list, :slug, :lang, :selected,
                :created_at, :updated_at, :cover, :category_name, :id,
                :recommended,
                :active #View attributes,

  def initialize(doc)
    @id = doc['id']
    @title = doc['title']
    @body = doc['body'] || ''
    @slug = doc['slug']
    @tabtitle = doc['tabtitle'] || @title
    @description = doc['description'] || ''
    @lang = doc['lang']
    @published = doc['published']
    @abstract = doc['abstract'] || ''
    @cover = doc['cover'] || ''
    @category_name = doc['category_name'] || ''
    @selected = doc['selected']
    @trainers_list = load_trainers(doc['trainers'])
    @active = false
    init_trainers(doc)
    init_dates(doc)
    init_recommended(doc)
  end

  def load_trainers(hash_trainers)
    return [] if hash_trainers.nil?

    hash_trainers.reduce([]) do |trainers, t_json|
      trainers << Trainer.new.load_from_json(t_json)
    end
  end

  def init_trainers(doc)
    @trainers = doc['trainers']&.reduce([]) { |ac, t| ac << t['name'] } || []
  end

  def init_dates(doc)
    @created_at = doc['created_at'] || ''
    @updated_at = doc['updated_at'] || ''
  end

  def init_recommended(doc)
    @recommended = doc['recommended']&.reduce([]) { |ac, r| ac << Recommended.new(r) } || []
  end

  def self.load_list(doc, only_published: false)
    doc.each_with_object([]) do |art, ac|
      a = Article.new(art)
      ac << a if !only_published || a.published
    end
  end
end
