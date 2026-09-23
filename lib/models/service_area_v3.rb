require './lib/models/service_v3'
require './lib/models/recommended'
require './lib/image_url_helper'
require './lib/testimony'

class ServiceAreaV3
  attr_accessor(*%i[id slug lang name summary primary_color primary_font_color secondary_color secondary_font_color slogan cta_message
                    subtitle description definitions defintions target value_proposition value_proposition_title
                    services seo_title seo_description target_title is_training_program ordering testimonies
                    recommended_way_title recommended_way_note recommended_way_summary recommended_way_details
                    outcomes program faq pricing recommended])
  attr_writer :icon, :side_image, :brochure

  def load_from_json(hash_service_area)
    @testimonies = []

    load_str(%i[id slug lang name icon summary primary_color primary_font_color secondary_color secondary_font_color cta_message
                slogan subtitle description definitions side_image target value_proposition value_proposition_title
                seo_title seo_description target_title is_training_program ordering
                recommended_way_title recommended_way_note pricing brochure], hash_service_area)

    @services = load_services(hash_service_area['services'])
    load_testimonies(hash_service_area['testimonies'])
    @recommended_way_summary = hash_service_area['recommended_way_summary']
    @recommended_way_details = hash_service_area['recommended_way_details']
    load_offering(hash_service_area)

    self
  end

  # The area as an offering in itself: the same blocks a service has.
  def load_offering(hash_service_area)
    @outcomes = hash_service_area['outcomes'] || []
    @program = hash_service_area['program'] || []
    @faq = hash_service_area['faq'] || []
    @recommended = Recommended.create_list(hash_service_area['recommended'] || [])
  end

  # Whether the area sells something on its own, i.e. it has the blocks a
  # service page is made of, and not only the intro to the services under it.
  def offering?
    [outcomes, program, faq].any? { |block| Array(block).any? }
  end

  def brochure
    ImageUrlHelper.replace_s3_with_cdn(@brochure)
  end

  def self.null_json_api(list_null_api, instance_null_api)
    @@json_api = [list_null_api, instance_null_api]
  end

  def self.create_list_keventer(programs = false)
    # Use the cached @@json_api if available, otherwise create a new JsonAPI instance
    response = if defined?(@@json_api)
                 value = @@json_api && @@json_api[0] # Use first element for list responses
                 if value.is_a?(Array)
                   value.shift # Pop from front (FIFO) rather than back
                 else
                   value
                 end
               else
                 url = programs ? KeventerAPI.programs_url : KeventerAPI.service_areas_url
                 KeventerAPI.echo(url)
                 JsonAPI.new(url)
               end

    return nil unless response&.ok?

    ServiceAreaV3.load_list(response.doc)
  end

  def self.try_create_list_keventer(programs = false)
    create_list_keventer(programs) || []
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
    response = if defined?(@@json_api)
                 @@json_api && @@json_api[1]
               else
                 url = if is_preview_mode
                         KeventerAPI.service_area_preview_url(slug)
                       else
                         KeventerAPI.service_area_url(slug)
                       end

                 JsonAPI.new(url)
               end

    return nil unless response&.ok?

    ServiceAreaV3.new.load_from_json(response.doc)
  end

  def load_services(doc)
    @services = doc.map do |service_hash|
      ServiceV3.new(service_hash)
    end
  end

  def load_testimonies(plane_testimonies)
    return if plane_testimonies.nil?

    plane_testimonies.each do |testimony|
      new_testimony = Testimony.new
      new_testimony.load_from_json(testimony)

      @testimonies.push(new_testimony)
    end
  end

  def icon
    ImageUrlHelper.replace_s3_with_cdn(@icon)
  end

  def side_image
    ImageUrlHelper.replace_s3_with_cdn(@side_image)
  end

  private

  def load_str(syms, hash)
    syms.each { |field| send("#{field}=", hash[field.to_s]) }
  end
end
