require './lib/models/service_v3'

class ServiceAreaV3
  attr_accessor(*%i[id slug lang name icon summary primary_color primary_font_color secondary_color secondary_font_color slogan cta_message
                    subtitle description definitions side_image defintions target value_proposition
                    services seo_title seo_description target_title])

  def load_from_json(hash_service_area)
    load_str(%i[id slug lang name icon summary primary_color primary_font_color secondary_color secondary_font_color cta_message
                slogan subtitle description definitions side_image target value_proposition
                seo_title seo_description target_title], hash_service_area)

    @services = load_services(hash_service_area['services'])
    self
  end

  def self.null_json_api(list_null_api, instance_null_api)
    @@json_api = [list_null_api, instance_null_api]
  end

  def self.create_list_keventer(programs = false)
    url = programs ? KeventerAPI.programs_url : KeventerAPI.service_areas_url
    KeventerAPI.echo(url)

    # Use the cached @@json_api if available, otherwise create a new JsonAPI instance
    response = if defined? @@json_api
                 @@json_api[0]
               else
                 JsonAPI.new(url)
               end

    raise :NotFound unless response.ok?

    ServiceAreaV3.load_list(response.doc)
  end

  def self.try_create_list_keventer(programs = false)
    create_list_keventer(programs)
  rescue :NotFound
    []
  end

  def self.load_list(doc)
    doc.each_with_object([]) do |service_area, ac|
      s = ServiceAreaV3.new
      s.load_from_json(service_area)
      s.lang ||= 'es'
      ac << s
    end
  end

  def self.create_keventer(slug, is_preview_mode = false)
    url = if is_preview_mode
            KeventerAPI.service_area_preview_url(slug)
          else
            KeventerAPI.service_area_url(slug)
          end
    response = if defined? @@json_api
                 @@json_api[1]
               else
                 JsonAPI.new(url)
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
