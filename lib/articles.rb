require './lib/keventer_connector'

class Article
  @next_null = false

  def self.create_one_null(art, opt = {})
    @next_null = opt[:next_null] == true
    @article_null = Article.new(art)
  end

  def self.create_one_keventer(slug)
    if @next_null
      @next_null = false
      return @article_null
    end
    uri = KeventerConnector.article_url(slug)
    api_resp = JsonAPI.new(uri)
    raise :NotFound unless api_resp.ok?

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
    uri = KeventerConnector.articles_url
    api_resp = JsonAPI.new(uri)
    raise :NotFound unless api_resp.ok?

    Article.load_list(api_resp.doc, only_published: only_published)
  end

  attr_accessor :title, :description, :tabtitle, :body, :published,
                :trainers, :slug, :abstract,
                :created_at, :updated_at

  def initialize(doc)
    @title = doc['title']
    @body = doc['body'] || ''
    @slug = doc['slug']
    @tabtitle = doc['tabtitle'] || @title
    @description = doc['description']
    @published = doc['published']
    @abstract = doc['abstract'] || ''
    init_trainers(doc)
    init_dates(doc)
  end

  def init_trainers(doc)
    @trainers = doc['trainers']&.reduce([]) { |ac, t| ac << t['name'] } || []
  end

  def init_dates(doc)
    @created_at = doc['created_at'] || ''
    @updated_at = doc['updated_at'] || ''
  end

  def self.load_list(doc, only_published: false)
    doc.each_with_object([]) do |art, ac|
      a = Article.new(art)
      ac << a if !only_published || a.published
    end
  end
end
