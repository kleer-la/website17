require './lib/xml_api'

class EventType
  def self.create_null(file)
    EventType.new XmlAPI.new(file)
  end

  def self.create_keventer(id)
    EventType.new XmlAPI.new(KeventerConnector.new.event_type_url(id))
  end

  attr_accessor :id, :duration, :lang, :cover,
                :name, :subtitle, :description, :learnings, :takeaways,
                :goal, :recipients, :program, :faq,
                :external_site_url, :elevator_pitch, :include_in_catalog,
                :deleted, :noindex,
                :categories, :slug, :canonical_slug,
                :is_kleer_cert, :is_sa_cert

  def initialize(provider = nil, hash_provider = nil)
    if provider
      @provider = provider
      load provider.xml_doc
    else
      @hash_provider = hash_provider
      load_complete_event(hash_provider)
    end
  end

  def load(xml_doc)
    @id = xml_doc.find('/event-type/id').first.content.to_i
    @duration = xml_doc.find('/event-type/duration').first.content.to_i
    @include_in_catalog = to_boolean(xml_doc.find_first('include-in-catalog').content)
    @deleted = to_boolean(xml_doc.find_first('deleted')&.content)
    @noindex = to_boolean(xml_doc.find_first('noindex')&.content)
    @is_kleer_cert = to_boolean(xml_doc.find_first('is-kleer-certification')&.content)
    @is_sa_cert = to_boolean(xml_doc.find_first('csd-eligible')&.content)

    %i[name subtitle description learnings takeaways cover
       goal recipients program faq slug canonical_slug lang
       external_site_url elevator_pitch include_in_catalog].each do |f|
      load_string(xml_doc, f)
    end
    load_categories xml_doc
  end

  # TODO: remove duplicarion w/keventer_reader
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

  def load_complete_event(hash_event) #json provider
    # puts hash_event['specific_subtitle']
    @id = hash_event['slug']
    # duration = hash_event[:id]
    @lang = hash_event['lang']
    @cover = hash_event['cover']
    @name = hash_event['name']
    @subtitle = hash_event['subtitle']
    @is_kleer_cert = hash_event['is_kleer_certification']
    @is_sa_cert = hash_event['csd_eligible']
    @categories = hash_event['categories'].map{|e| e['name']}

  end
end
