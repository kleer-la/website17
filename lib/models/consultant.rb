require './lib/json_api'

class Consultant
  attr_accessor :id, :name, :bio, :gravatar_email,
                :signature_credentials, :linkedin_url, :role

  def initialize(lang = 'es')
    @name = @bio = @gravatar_email = @linkedin_url = @role = ''
    @lang = lang
  end

  def load_from_json(json)
    @id = json['id'].to_i
    load_str(%i[name bio gravatar_email signature_credentials linkedin_url], json)
    @role = @signature_credentials.to_s
    @bio = json['bio_en'].to_s if @lang == 'en'
    self
  end

  def gravatar_picture_url
    hash = 'default'
    hash = Digest::MD5.hexdigest(gravatar_email) unless gravatar_email.nil?
    "https://www.gravatar.com/avatar/#{hash}"
  end

  class << self
    attr_writer :api_client

    def for_service_area(slug, lang = 'es')
      json_api = @api_client || JsonAPI.new(KeventerAPI.consultants_for_area_url(slug))
      return [] unless json_api.ok? && json_api.doc

      json_api.doc.map { |c| Consultant.new(lang).load_from_json(c) }
    end

    def availability(consultant_id, start_date, end_date, timezone = nil)
      params = { start: start_date, end: end_date }
      params[:timezone] = timezone if timezone
      url = KeventerAPI.consultant_availability_url(consultant_id, params)
      json_api = @api_client || JsonAPI.new(url)
      return nil unless json_api.ok?

      json_api.doc
    end

    def null_json_api(null_api)
      @api_client = null_api
    end
  end

  private

  def load_str(syms, hash)
    syms.each { |field| send("#{field}=", hash[field.to_s]) }
  end
end
