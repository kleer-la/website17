class EventType
  def self.createNull(file)
    EventType.new NullEventType.new(file)
  end

  attr_accessor :id, :duration, 
                :name, :subtitle, :description, :learnings, :takeaways,
                :goal, :recipients, :program

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
  end

  def load_string(xml, field)
    element= xml.find("/event-type/#{field}").first
    send("#{field}=", element.content) if not element.nil?
  end
end


class NullEventType
  attr_accessor :xml_doc
  def initialize(file)
    xml= LibXML::XML::Parser.file(file)
    @xml_doc= xml.parse
  end

end
