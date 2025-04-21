require './lib/services/keventer_api'

class Contact
  attr_accessor :name, :company, :email, :status, :assessment_report_url, :assessment, :id

  def initialize(data)
    @id = data['id']
    @name = data['name']
    @email = data['email']
    @status = data['status']
    @assessment_report_url = data['assessment_report_url']
    @assessment = Assessment.new(data['assessment']) if data['assessment']
  end

  @next_null = false
  @contact_null = nil

  def self.create_one_null(data, opt = {})
    @next_null = opt[:next_null] == true
    @contact_null = Contact.new(data)
  end

  def self.create_one_keventer(id)
    if @next_null
      @next_null = false
      return @contact_null
    end

    api_resp = JsonAPI.new(KeventerAPI.contact_url(id))
    raise ContactNotFoundError.new(id) unless api_resp.ok?

    Contact.new(api_resp.doc)
  end

  # def self.load_from_json(file_path)
  #   data = JSON.parse(File.read(file_path))
  #   data['podcasts'].map do |podcast_data|
  #     new(podcast_data)
  #   end
  # end

  # def self.load_from_keventer
  #   url = KeventerAPI.podcasts_url
  #   json_api = JsonAPI.new(url)
  #   load(json_api)
  # end

  # def self.load(json_api)
  #   json_api.doc.map { |podcast_data| new(podcast_data) } if json_api.ok?
  # end
end

class ContactNotFoundError < StandardError
  def initialize(id)
    super("Contact with ID '#{id}' not found")
  end
end