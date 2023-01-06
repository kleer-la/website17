require './lib/json_api'

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

  def load_from_json(cat, lang)
    suffix = lang == 'en' ? '_en' : ''
    @name = cat["name#{suffix}"]
    @codename = cat['codename']
    @tagline = cat["tagline#{suffix}"]
    @description = cat["description#{suffix}"]
    @order = cat['order']
    self
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

  class << self
    def create_keventer_json(lang)
      if defined? @@json_api
        json_api = @@json_api
      else
        json_api = JsonAPI.new(KeventerConnector.categories_json_url)
      end
      Category.load_categories(json_api.doc, lang) unless json_api.doc.nil?
    end

    def null_json_api(null_api)
      @@json_api = null_api
    end
    def load_categories(cat_json, lang)
      cat_json.reduce([]) { |ac, cat| ac << Category.new(nil).load_from_json(cat, lang) }
    end
  end
end
