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

  def self.createListNull(arts, opt = {})
    @next_null = opt[:next_null] == true
    @articlesNull = Article.load_list(arts, opt[:only_published])
  end

  def self.create_list_keventer(only_published)
    if @next_null
      @next_null = false
      return @articlesNull
    end
    uri = KeventerConnector.articles_url
    api_resp = JsonAPI.new(uri)
    if !api_resp.ok?
      raise :NotFound
    else
      Article.load_list(api_resp.doc, only_published)
    end
  end

  attr_accessor :title, :description, :tabtitle, :body, :published,
                :trainers, :slug, :abstract,
                :created_at, :updated_at

  def initialize(doc)
    @title = doc['title']
    @body = doc['body'] || ''
    @slug = doc['slug']
    @tabtitle = doc['tabtitle']
    @tabtitle = @title if @tabtitle == ''
    @description = doc['description']
    @published = doc['published']
    @trainers = doc['trainers']&.reduce([]) { |ac, t| ac << t['name'] } || []
    @created_at = doc['created_at'] || ''
    @updated_at = doc['updated_at'] || ''
    @abstract = doc['abstract'] || ''
  end

  def self.load_list(doc, only_published = false)
    doc.each_with_object([]) do |art, ac|
      a = Article.new(art)
      ac << a if !only_published || a.published
    end
  end
end
