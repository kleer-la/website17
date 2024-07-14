class Recommended
  attr_reader :title, :subtitle, :slug, :cover, :type

  def initialize(doc)
    @title = doc['title']
    @subtitle = doc['subtitle']
    @slug = doc['slug']
    @cover = doc['cover']
    @type = doc['type']
  end
end