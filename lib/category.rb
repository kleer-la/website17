require './lib/json_api'

class Category
  attr_accessor :name, :description, :tagline, :codename, :order, :event_types

  def initialize(lang = 'es')
    @name = @description = @tagline = @codename = ''
    @order = 0
    @event_types = []
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

  class << self
    def create_keventer_json(lang)
      if defined? @@json_api
        json_api = @@json_api
      else
        json_api = JsonAPI.new(KeventerAPI.categories_url)
      end
      Category.load_categories(json_api.doc, lang) unless json_api.doc.nil?
    end

    def null_json_api(null_api)
      @@json_api = null_api
    end
    def load_categories(cat_json, lang)
      cat_json.reduce([]) { |ac, cat| ac << Category.new(lang).load_from_json(cat, lang) }
    end
  end
end
