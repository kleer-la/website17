require './lib/models/service_v3'

class ServiceAreaV3
  attr_accessor(*%i(id slug name icon summary primary_color secondary_color slogan cta_message
                  subtitle description definitions side_image defintions target value_proposition
                  services seo_title seo_description target_title))

  def load_from_json(hash_service_area)
    load_str(%i[id slug name icon summary primary_color secondary_color cta_message
              slogan subtitle description definitions side_image target value_proposition
              seo_title seo_description target_title], hash_service_area)

    @services = load_services(hash_service_area["services"])
    self
  end

  def self.null_json_api(null_api)
    @@json_api = null_api
  end

  def self.create_list_keventer
    if defined? @@json_api
      response = @@json_api
    else
      response = JsonAPI.new(KeventerConnector.service_areas_url)
    end

    raise :NotFound unless response.ok?

    ServiceAreaV3.load_list(response.doc)
  end

  def self.load_list(doc)
    doc.each_with_object([]) do |service_area, ac|
      s = ServiceAreaV3.new
      s.load_from_json(service_area)
      ac << s
    end
  end

  def self.create_keventer(slug)
    if defined? @@json_api
      response = @@json_api
    else
      response = JsonAPI.new(KeventerConnector.service_area_url(slug))
    end

    return nil unless response.ok?

    ServiceAreaV3.new.load_from_json(response.doc)
  end

  def load_services(doc)
    @services = doc.map do |service_hash|
      ServiceV3.new(service_hash)
    end
  end

  private

  def load_str(syms, hash)
    syms.each { |field| send("#{field}=", hash[field.to_s]) }
  end
end
