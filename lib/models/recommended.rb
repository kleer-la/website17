class Recommended
  attr_reader :title, :subtitle, :slug, :cover, :type

  def initialize(doc)
    @title = doc['title']
    @subtitle = doc['subtitle']
    @slug = doc['slug']
    @cover = doc['cover']
    @type = doc['type']
  end

  def url
    raise NotImplementedError, "#{self.class} must implement the 'url' method"
  end

  def self.create(doc)
    case doc['type']
    when 'article'
      RecommendedArticle.new(doc)
    when 'event_type'
      RecommendedEventType.new(doc)
    when 'service'
      RecommendedService.new(doc)
    else
      raise ArgumentError, "Unknown recommendation type: #{doc['type']}"
    end
  end
end

class RecommendedArticle < Recommended
  def url
    "/es/blog/#{slug}"
  end
end

class RecommendedEventType < Recommended
  def initialize(doc)
    super(doc)
    @external_url = doc['external_url']
  end

  def url
    @external_url || "/es/cursos/#{slug}"
  end
end

class RecommendedService < Recommended
  def url
    "/es/servicios/#{slug}"
  end
end
