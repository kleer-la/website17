require 'faraday'
require 'json'

# TODO: move to lib/services
class JsonAPI
  attr_accessor :doc

  def initialize(uri)
    @response = Faraday.get(uri)
    @doc = JSON.parse(@response.body) if ok?
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
