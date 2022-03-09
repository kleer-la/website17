class Category
  attr_accessor :name, :description, :tagline, :codename, :order, :event_types

  def initialize(xml = nil, lang = 'es')
    @name = @description = @tagline = @codename = ''
    @order = 0
    @event_types = []

    load(xml, lang == 'en' ? '-en' : '') unless xml.nil?
  end

  def load(xml, suffix)
    @name = xml.find_first("name#{suffix}").content
    @codename = xml.find_first('codename').content
    @tagline = xml.find_first("tagline#{suffix}").content
    @description = xml.find_first("description#{suffix}").content
    @order = xml.find_first('order').content.to_i
  end

  # load catalog data: category/event_type
  # from a parsed xml
  def self.categories(loaded_categories, lang = 'es')
    categories = []
    loaded_categories.each do |loaded_category|
      category = Category.new loaded_category, lang

      category.event_types = load_event_types loaded_category

      categories << category
    end

    categories.sort! { |p, q| p.order <=> q.order }

    categories
  end
end
