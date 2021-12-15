class Article
  attr_accessor :title, :description, :tabtitle, :body, :published, 
                :trainers,
                :created_at, :updated_at

  def initialize(doc)
    @title = doc['title']
    @body = doc['body']
    @tabtitle = doc['tabtitle']
    @tabtitle = @title if @tabtitle == ''
    @description = doc['description']
    @published = doc['published']
    @trainers = doc['trainers']&.reduce([]) {|ac,t| ac << t['name']}
    @created_at = doc['created_at']
    @updated_at = doc['updated_at']
  end

  def self.load_list(doc)
    doc.reduce([]) do |ac, art|
      ac << Article.new(art)
    end
  end
end
