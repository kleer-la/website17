#TODO: remove
require './lib/models/service_model'

class LocalReader
  def initialize(connector = nil)
    @connector = connector
  end

  def load_service(service_name)
    #TODO: create a local json connector
    file = File.read('./lib/storage/services_storage.json')
    hash_service = JSON.parse(file)[service_name]

    return nil if hash_service.nil?

    service = Service.new
    service.load_from_json(hash_service)
    service
  end
end
