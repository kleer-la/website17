require './lib/xml_api'
require './lib/json_api'
require './lib/keventer_helper'
require './lib/keventer_connector'

class EventType
  def self.create_null(file)
    EventType.new XmlAPI.new(file)
  end

  def self.create_keventer(id) #TODO deprecate
    EventType.new XmlAPI.new(KeventerConnector.new.event_type_url(id))
  end

  def self.create_keventer_json(id)
    if defined? @@json_api
      json_api = @@json_api
    else
      json_api = JsonAPI.new(KeventerConnector.new.event_type_url(id, :json))
    end

    et = EventType.new(nil, json_api.doc ) unless json_api.doc.nil?
    et unless et&.id.nil?
  end

  def self.null_json_api(null_api)
    @@json_api = null_api
  end


  attr_accessor :id, :duration, :lang, :cover, :name, :subtitle, :description, :learnings, :takeaways,
                :goal, :recipients, :program, :faq, :external_site_url, :elevator_pitch, :include_in_catalog,
                :deleted, :noindex, :categories, :slug, :canonical_slug, :is_kleer_cert, :is_sa_cert,
                :public_editions, :side_image, :brochure, :is_new_version, :testimonies

  def initialize(provider = nil, hash_provider = nil)
    if provider
      @provider = provider
      load provider.xml_doc
    else #TODO check if hash_provider is nil
      @hash_provider = hash_provider
      @id= nil
      @testimonies = []
      load_complete_event(hash_provider)
    end
  end

  def load(xml_doc)   #TODO deprecate
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

  def load_categories(xml_doc) #TODO deprecate
    @categories = []
    xml_doc.find('//categories/category').each do |xml_cat|
      id = xml_cat.find('id').first.content.to_i
      codename = xml_cat.find('codename').first.content
      @categories << [id, codename]
    end
    @categories
  end

  def load_complete_event(hash_event) #json provider
    return if hash_event.nil? || ['id'].nil?

    @id =  hash_event['id'].nil? ? hash_event['event_type_id'].to_i : hash_event['id'].to_i
    @duration = hash_event['duration'].to_i
    @is_kleer_cert = to_boolean(hash_event['is_kleer_certification'])
    @is_sa_cert = to_boolean(hash_event['csd_eligible'])
    @is_new_version = to_boolean(hash_event['new_version'])
    @categories = hash_event['categories'].map{|e| e['name']} unless hash_event['categories'].nil?

    load_testimonies(hash_event['testimonies'])

    %i[name subtitle description learnings takeaways cover
      goal recipients program faq slug canonical_slug lang
      external_site_url elevator_pitch include_in_catalog
      side_image brochure deleted
    ].each { |field| send("#{field}=", hash_event[field.to_s]) }

    @public_editions = load_public_editions(hash_event['next_events'])
  end

  def load_public_editions(next_events)
    return [] if next_events.nil?

    next_events.reduce([]) do |events, ev_json|
      events << Event.new(self).load_from_json(ev_json)
    end
  end

  def load_testimonies(plane_testimonies)
    unless plane_testimonies.nil?
      plane_testimonies.each do |testimony|
        new_testimony = Testimony.new
        new_testimony.load_from_json(testimony)

        @testimonies.push(new_testimony)
      end
    end
  end

  def uri_path
    "/#{@lang}/cursos/#{@slug}"
  end
  def canonical_url
    "/#{@lang}/cursos/#{@canonical_slug}" if @canonical_slug.to_s != ''
  end

  def redirect_to(event_type_id_with_name)
    return ''                   if @deleted && @canonical_slug == @slug     # dont know where to redirect
    return ''                   if @deleted && @canonical_slug.to_s == ''   # dont know where to redirect
    return self.canonical_url   if @deleted && @canonical_slug.to_s != ''   # redirect to canonical
    return self.uri_path        if event_type_id_with_name != @slug         # redirect to itself
    nil                                                                     # dont redirect
  end

end
