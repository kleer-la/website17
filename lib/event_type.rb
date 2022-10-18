require './lib/xml_api'
require './lib/json_api'
require './lib/keventer_helper'
require './lib/keventer_connector'

class EventType
  def self.create_null(file)
    EventType.new XmlAPI.new(file)
  end

  def self.create_keventer(id)
    EventType.new XmlAPI.new(KeventerConnector.new.event_type_url(id))
  end

  def self.create_keventer_json(id)
    EventType.new(nil, JsonAPI.new(KeventerConnector.new.event_type_url(id, :json)).doc )
  end

  attr_accessor :id, :duration, :lang, :cover,
                :name, :subtitle, :description, :learnings, :takeaways,
                :goal, :recipients, :program, :faq,
                :external_site_url, :elevator_pitch, :include_in_catalog,
                :deleted, :noindex,
                :categories, :slug, :canonical_slug,
                :is_kleer_cert, :is_sa_cert,
                :public_editions, :side_image, :is_new_version

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
    @id = hash_event['id'].to_i
    @duration = hash_event['duration'].to_i
    @is_kleer_cert = to_boolean(hash_event['is_kleer_certification'])
    @is_sa_cert = to_boolean(hash_event['csd_eligible'])
    @is_new_version = to_boolean(hash_event['is_new_version'])
    @categories = hash_event['categories'].map{|e| e['name']} unless hash_event['categories'].nil?

    %i[name subtitle description learnings takeaways cover
      goal recipients program faq slug canonical_slug lang
      external_site_url elevator_pitch include_in_catalog
      side_image
    ].each do |field|
        # p "#{field}=#{hash_event[field.to_s]}"
        send("#{field}=", hash_event[field.to_s])
    end
    @public_editions = []      #TODO
  end

  def uri_path
    "cursos/#{@slug}"
  end
  def canonical_url
    "cursos/#{@canonical_slug}" if @canonical_slug.to_s != ''
  end

end
