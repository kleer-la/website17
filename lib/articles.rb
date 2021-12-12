class Article
  
  attr_accessor :title, :description, :tabtitle, :body, :published,:created_at, :updated_at
  
  def initialize(doc)
    p doc
    @title= doc['title']
    @body= doc['body']
    @tabtitle= doc['tabtitle']
    if @tabtitle == '' 
      @tabtitle = @title
    end
    @description= doc['description']
    @published= doc['published']
    @created_at= doc['created_at']
    @updated_at= doc['updated_at']
  end
  
end