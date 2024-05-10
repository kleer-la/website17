#TODO: remove
class Service
  attr_accessor :id, :name, :subtitle, :description, :side_image, :takeaways, :summary, :primary_color, :secondary_color, :icon, :services, :slug,
                :recipients, :program, :brochure, :titles, :seo_title, :color_theme,
                :cta, :canonical_url, :elevator_pitch, :sub_services, :contact_text, :logo, :cta_message
  def initialize()
    @public_editions = []
    @side_image = ''
  end

  def load_from_json(hash_service)
    load_str(%i[id
                     name
                     subtitle
                     description
                     side_image
                     color_theme
                     takeaways
                     recipients
                     program
                     brochure
                     cta
                     canonical_url
                     elevator_pitch
                     seo_title
                     contact_text
                     titles], hash_service)
    @sub_services = hash_service["sub-services"]
  end

  def load_short_from_json(hash_service)
    load_str(%i[id
                     name
                     summary
                     cta_message
                     takeaways
                     primary_color
                     secondary_color
                     canonical_url
                     icon
                     slug
                     elevator_pitch
                     contact_text
                     titles], hash_service)
    @sub_services = hash_service["sub-services"]
    @summary = @summary.gsub("\n", '<br>')

    @services = hash_service["services"].map do |service|
      s = NewService.new
      s.load_short_from_json(service)
      s
    end

  end

  def load_str(syms, hash)
    syms.each { |field| send("#{field}=", hash[field.to_s]) }
  end

  def self.load_list
    file = File.read('./lib/storage/service_areas_storage.json')
    hash_service = JSON.parse(file)

    hash_service.each_with_object([]) do |service, ac|
      s = Service.new
      s.load_short_from_json(service[1])
      ac << s
    end
  end
end

class NewService
  attr_accessor :name, :subtitle, :description, :outcomes, :abstract,
                :url, :id, :slug, :cta_message
  def initialize
  end

  def load_from_json(hash_service)
    load_str(%i[id
                      name
                     subtitle
                     description
                     abstract
                     outcomes
                     slug
                     url
                     ], hash_service)
  end

  def load_short_from_json(hash_service)
    load_str(%i[id name url slug
                     subtitle], hash_service)
  end

  def load_str(syms, hash)
    syms.each { |field| send("#{field}=", hash[field.to_s]) }
  end
end
