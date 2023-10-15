
class Service
  attr_accessor :name, :subtitle, :description, :side_image, :takeaways,
                :recipients, :program, :brochure, :titles, :seo_title,
                :cta, :canonical_url, :elevator_pitch, :sub_services, :contact_text
  def initialize()
    @public_editions = []
    @side_image = ''
  end

  def load_from_json(hash_service)
    load_str(%i[name
                     subtitle
                     description
                     side_image
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
    load_str(%i[name
                     subtitle
                     takeaways
                     elevator_pitch
                     contact_text
                     titles], hash_service)
    @sub_services = hash_service["sub-services"]
  end

  def load_str(syms, hash)
    syms.each { |field| send("#{field}=", hash[field.to_s]) }
  end

  def self.load_list
    file = File.read('./lib/storage/services_storage.json')
    hash_service = JSON.parse(file)

    hash_service.each_with_object([]) do |service, ac|
      s = Service.new
      s.load_short_from_json(service[1])
      ac << s
    end
  end
end
