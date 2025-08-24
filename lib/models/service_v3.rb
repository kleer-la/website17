require './lib/image_url_helper'
require './lib/models/recommended'

class ServiceV3
  attr_accessor(*%i[id name subtitle value_proposition outcomes definitions program target pricing faq url
                    slug recommended])
  attr_writer :brochure, :side_image

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

  def brochure
    ImageUrlHelper.replace_s3_with_cdn(@brochure)
  end

  def side_image
    ImageUrlHelper.replace_s3_with_cdn(@side_image)
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
