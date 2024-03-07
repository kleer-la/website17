class ServiceArea
  attr_accessor :name, :summary, :primary_color, :secondary_color, :icon

  def load_from_json(hash_service_area)
    load_str(%i[name
                summary
                primary_color
                secondary_color
                icon], hash_service_area)
  end

  def null_json_api(null_api)
    @json_api = null_api
  end

  def load_str(syms, hash)
    syms.each { |field| send("#{field}=", hash[field.to_s]) }
  end

  def self.load_list(doc)
    doc.each_with_object([]) do |service_area, ac|
      s = ServiceArea.new
      s.load_from_json(service_area)
      ac << s
    end
  end

  def self.create_list_keventer
    uri = KeventerConnector.service_areas_url
    response = JsonAPI.new(uri)

    raise :NotFound unless response.ok?

    ServiceArea.load_list(response.doc)
  end
end
