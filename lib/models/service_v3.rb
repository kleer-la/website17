class ServiceV3
  attr_accessor(*%i[id name subtitle value_proposition outcomes definitions program target pricing brochure faq url
                    slug side_image recommended])

  def initialize(hash_service)
    load_from_json(hash_service)
  end

  def load_from_json(hash_service)
    load_str(%i[id name subtitle value_proposition definitions target pricing brochure slug side_image],
             hash_service)

    @outcomes = hash_service['outcomes']
    @program = hash_service['program']
    @faq = hash_service['faq']
    @recommended = Recommended.create_list(hash_service['recommended'] || [])

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
