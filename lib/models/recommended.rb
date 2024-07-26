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
      puts "Unknown recommendation type: #{doc['type']}"
      # raise ArgumentError, "Unknown recommendation type: #{doc['type']}"
    end
  end
  def self.create_list(doc)
    doc&.reduce([]) do |ac, r|
      recommendation = Recommended.create(r)
      ac << recommendation if recommendation
      ac
    end || []
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
    @external_url.empty? ? "/es/cursos/#{slug}" : @external_url
  end
end

class RecommendedService < Recommended
  def url
    "/es/servicios/#{slug}"
  end
end
