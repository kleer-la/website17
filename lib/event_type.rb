require './lib/xml_api'

class EventType
  def self.createNull(file)
    EventType.new XmlAPI.new(file)
  end

  def self.createKeventer(id)
    EventType.new XmlAPI.new(KeventerConnector.new.event_type_url(id))
  end

  attr_accessor :id, :duration,
                :name, :subtitle, :description, :learnings, :takeaways,
                :goal, :recipients, :program, :faq,
                :external_site_url, :elevator_pitch, :include_in_catalog,
                :categories

  def initialize(provider)
    @provider = provider
    load provider.xml_doc
  end

  def load(xml_doc)
    @id = xml_doc.find('/event-type/id').first.content.to_i
    @duration = xml_doc.find('/event-type/duration').first.content.to_i

    %i[name subtitle description learnings takeaways
       goal recipients program faq
       external_site_url elevator_pitch include_in_catalog].each do |f|
      load_string(xml_doc, f)
    end
    load_categories xml_doc
  end

  #TODO remove duplicarion w/keventer_reader
  def load_string(xml, field)
    element = xml.find("/event-type/#{field.to_s.gsub('_', '-')}").first
    send("#{field}=", element.content) unless element.nil?
  end

  def load_categories(xml_doc)
    @categories = []
    xml_doc.find('//categories/category').each do |xml_cat|
      id = xml_cat.find('id').first.content.to_i
      codename = xml_cat.find('codename').first.content
      @categories << [id, codename]
    end
    @categories
  end
end
