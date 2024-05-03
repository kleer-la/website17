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

  def null_json_api(null_api)
    @json_api = null_api
  end

  def load_str(syms, hash)
    syms.each { |field| send("#{field}=", hash[field.to_s]) }
  end

  def self.create_keventer(slug)
    uri = KeventerConnector.service_area_url(slug)    
    response = JsonAPI.new(uri)

    raise :NotFound unless response.ok?

    ServiceAreaV3.new.load_from_json(response.doc)
  end

  def load_services(doc)
    @services = doc.map do |service_hash|
      ServiceV3.new(service_hash)
    end
  end
end

class ServiceV3
  attr_accessor(*%i(id name subtitle value_proposition outcomes definitions program target pricing brochure faq url slug side_image))

  def initialize(hash_service_area)
    load_from_json(hash_service_area)
  end

  def load_from_json(hash_service_area)
    load_str(%i[id name subtitle value_proposition definitions target pricing brochure slug side_image], hash_service_area)

    puts @side_image

    @outcomes = hash_service_area['outcomes']
    @program = hash_service_area['program']
    @faq = hash_service_area['faq']

    self
  end

  def null_json_api(null_api)
    @json_api = null_api
  end

  def load_str(syms, hash)
    syms.each { |field| send("#{field}=", hash[field.to_s]) }
  end
end

# services": [
# {
# "name": "Agilidad organizacional",
# "subtitle": "<div>Cambia tu organizacion</div>",
# "value_proposition": "<div class=\"trix-content\">\n  <div>Cambia tu organizacion</div>\n</div>\n",
# "outcomes": [],
# "definitions": "<div class=\"trix-content\">\n  <div>Cambia tu organizacion</div>\n</div>\n",
# "program": [],
# "target": "<div class=\"trix-content\">\n  <div>Cambia tu organizacion</div>\n</div>\n",
# "pricing": "",
# "brochure"

# "services": [
# {
# "name": "Agilidad organizacional",
# "subtitle": "<div>Cambia tu organizacion</div>",
# "value_proposition": "<div class=\"trix-content\">\n  <div>Cambia tu organizacion</div>\n</div>\n",
# "outcomes": [],
# "definitions": "<div class=\"trix-content\">\n  <div>Cambia tu organizacion</div>\n</div>\n",
# "program": [],
# "target": "<div class=\"trix-content\">\n  <div>Cambia tu organizacion</div>\n</div>\n",
# "pricing": "",
# "brochure": ""
# },
