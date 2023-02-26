
class Service
  attr_accessor :name, :subtitle, :description, :side_image, :takeaways,
                :recipients, :program, :brochure,
                :cta, :canonical_url, :elevator_pitch
  def initialize()
    @public_editions = []
    @side_image = ''
  end

  def load_from_json(hash_service)
    load_str(%i[name subtitle description side_image takeaways recipients program brochure cta canonical_url elevator_pitch], hash_service)
  end

  def load_str(syms, hash)
    syms.each { |field| send("#{field}=", hash[field.to_s]) }
  end
end
