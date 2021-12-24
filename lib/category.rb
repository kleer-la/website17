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
end
