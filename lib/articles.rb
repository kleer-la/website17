class Article
  @@next_null = false

  def self.createOneNull(art, opt= {})
    @@next_null = opt[:next_null] == true
    @@articleNull = Article.new(art)
  end
  
  def self.createOneKeventer(slug)
    if @@next_null
      @@next_null=false
      return @@articleNull
    end
    # KeventerConnector.new.event_type_url(id)
    uri = "http://keventer-test.herokuapp.com/articles/#{slug}.json"
    api_resp = JsonAPI.new(uri)
    if !api_resp.ok?
      raise :NotFound
    else
      Article.new(api_resp.doc)
    end
  end

  def self.createListNull(arts, opt= {})
    @@next_null = opt[:next_null] == true
    @@articlesNull = Article.load_list(arts)
  end
  
  def self.createListKeventer
    if @@next_null
      @@next_null=false
      return @@articlesNull
    end
    # KeventerConnector.new.event_type_url(id)
    uri = "http://keventer-test.herokuapp.com/articles.json"
    api_resp = JsonAPI.new(uri)
    if !api_resp.ok?
      raise :NotFound
    else
      Article.load_list(api_resp.doc)
    end
  end

  attr_accessor :title, :description, :tabtitle, :body, :published, 
                :trainers, :slug,
                :created_at, :updated_at

  def initialize(doc)
    @title = doc['title']
    @body = doc['body'] || ''
    @slug = doc['slug']
    @tabtitle = doc['tabtitle']
    @tabtitle = @title if @tabtitle == ''
    @description = doc['description']
    @published = doc['published']
    @trainers = doc['trainers']&.reduce([]) {|ac,t| ac << t['name']} || []
    @created_at = doc['created_at'] || ''
    @updated_at = doc['updated_at'] || ''
  end

  def self.load_list(doc)
    doc.reduce([]) do |ac, art|
      ac << Article.new(art)
    end
  end
end
