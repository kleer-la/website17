require 'faraday'
require 'json'

class JsonAPI
  attr_accessor :doc
  def initialize(uri)
    @response = Faraday.get(uri)
    @doc= JSON.parse(@response.body) if ok?
  end
  def ok?
    @response.status == 200
  end
end
