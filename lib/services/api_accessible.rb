require 'httparty'

module APIAccessible
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def api_connector(connector_class)
      @api_connector = connector_class
    end

    def create_from_api(id)
      if defined? @json_api
        json_api = @json_api
      else
        url = @api_connector.new.url_for(id)
        json_api = JsonAPI.new(url)
      end

      new(json_api.doc) if json_api.ok?
    end

    def null_json_api(null_api)
      @json_api = null_api
    end
  end

  class JsonAPI
    include HTTParty

    attr_reader :doc

    def initialize(url)
      @response = self.class.get(url)
      @doc = @response.parsed_response if ok?
    end

    def ok?
      @response.success?
    end
  end

  class NullJsonAPI
    attr_reader :doc

    def initialize(file_path_or_json)
      @doc = if File.exist?(file_path_or_json)
              JSON.parse(File.read(file_path_or_json))
            else
              JSON.parse(file_path_or_json)
            end
    rescue JSON::ParserError
      nil
    end

    def ok?
      !@doc.nil?
    end
  end
end
