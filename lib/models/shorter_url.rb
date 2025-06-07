require './lib/json_api'
require './lib/services/keventer_api'

class ShorterUrl

  class << self
    attr_accessor :json_api
    @@json_api = nil

    def set_json_api(json_api)
      @@json_api = json_api
    end

    def create_keventer(short_code)
      response = if !@@json_api.nil?
                    @@json_api
                  else
                    JsonAPI.new(KeventerAPI.short_url_url(short_code))
                  end

      return nil unless response&.ok?

      ShorterUrl.new(response.doc)
    end
  end


  attr_reader :original_url
  def initialize(doc = nil)
    @original_url = nil
    @original_url = doc['original_url'] if doc
  end
end
