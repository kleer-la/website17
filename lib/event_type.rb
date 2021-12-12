require './lib/xml_api.rb'

class EventType
  def self.createNull(file)
    EventType.new XmlAPI.new(file)
  end

  def self.createKeventer(id)
    EventType.new XmlAPI.new(KeventerConnector.new.event_type_url(id))
  end

  attr_accessor :id, :duration, 
                :name, :subtitle, :description, :learnings, :takeaways,
                :goal, :recipients, :program,
                :categories

  def initialize(provider)
    @provider= provider
    load provider.xml_doc
  end

  def load xml_doc
    @id  = xml_doc.find('/event-type/id').first.content.to_i
    @duration = xml_doc.find('/event-type/duration').first.content.to_i

    [:name, :subtitle, :description, :learnings, :takeaways,
      :goal, :recipients, :program].each {
      |f| load_string(xml_doc, f)
    }
    @external_site_url = xml_doc.find('external-site-url')&.first&.content
    @faqs  = xml_doc.find('faq').first.content
    @elevator_pitch = xml_doc.find('elevator-pitch').first.content
    @include_in_catalog = to_boolean( xml_doc.find('include-in-catalog').first.content )
    load_categories xml_doc
  end

  def load_string(xml, field)
    element= xml.find("/event-type/#{field}").first
    send("#{field}=", element.content) if not element.nil?
  end

  def load_categories xml_doc
    @categories= []
    xml_doc.find('//categories/category').each do |xml_cat|
      id= xml_cat.find('id').first.content.to_i
      codename= xml_cat.find('codename').first.content
      @categories << [id,codename]
    end
    @categories
  end
end
