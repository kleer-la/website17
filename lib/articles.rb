class Article
  attr_accessor :title, :description, :tabtitle, :body, :published, :created_at, :updated_at

  def initialize(doc)
    @title = doc['title']
    @body = doc['body']
    @tabtitle = doc['tabtitle']
    @tabtitle = @title if @tabtitle == ''
    @description = doc['description']
    @published = doc['published']
    @created_at = doc['created_at']
    @updated_at = doc['updated_at']
  end
end
