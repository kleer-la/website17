require 'faraday'
require 'json'

# TODO: move to lib/services
class JsonAPI
  attr_accessor :doc

  def initialize(uri)
    @response = Faraday.get(uri)
    if ok?
      begin
        @doc = JSON.parse(@response.body)
      rescue JSON::ParserError => e
        unless ENV['RACK_ENV'] == 'test'
          puts "JSON Parse Error for URL: #{uri}"
          puts "Response Body: #{@response.body}"
          puts "Error: #{e.message}"
        end
        raise e
      end
    else
      unless ENV['RACK_ENV'] == 'test'
        puts "HTTP Error for URL: #{uri}"
        puts "Status: #{@response.status}"
        puts "Response Body: #{@response.body}"
      end
    end
  end

  def ok?
    @response.status == 200
  end

  def response
    @doc
  end
end

class NullJsonAPI
  attr_accessor :doc

  def initialize(uri, doc = nil)
    if uri.nil?
      @doc = nil
      @doc = JSON.parse(doc) unless doc.nil?
    else
      @doc = JSON.parse(File.read(uri))
    end
  end

  def ok?
    !@doc.nil?
  end

  def response
    @doc
  end
end
