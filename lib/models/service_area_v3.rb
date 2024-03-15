class ServiceAreaV3
  attr_accessor(*%i(slug name icon summary primary_color secondary_color slogan
                  subtitle description side_image target value_proposition services))

  def load_from_json(hash_service_area)
    load_str(%i[slug name icon summary primary_color secondary_color
              slogan subtitle description side_image target value_proposition], hash_service_area)

    @services = load_services(hash_service_area["services"])
    self
  end

  def null_json_api(null_api)
    @json_api = null_api
  end

  def load_str(syms, hash)
    syms.each { |field| send("#{field}=", hash[field.to_s]) }
  end

  # def self.load_list(doc)
  #   doc.each_with_object([]) do |service_area, ac|
  #     s = ServiceAreaV3.new
  #     s.load_from_json(service_area)
  #     ac << s
  #   end
  # end

  def self.create_keventer(slug)
    uri = KeventerConnector.service_area_url(slug)
    
    response = JsonAPI.new(uri)
    # response = JsonAPI.new("https://eventos.kleer.la/api/service_areas/cambio-organizacional")

    raise :NotFound unless response.ok?

    ServiceAreaV3.new.load_from_json(response.doc)
  end

  def load_services(doc)
    return []
    @services = doc.map do |service_hash|
      service = NewService.new
      service.load_short_from_json(service_hash)
      service
    end
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