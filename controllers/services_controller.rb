require './lib/models/service_model'
require './lib/readers/local_reader'

get '/servicios/:service_id' do
  service_id = params[:service_id]

  reader = LocalReader.new
  @event_type = reader.load_service(service_id)

  @meta_tags.set! title: 'Programa de Desarrollo del Liderazgo Ágil'
  @meta_tags.set! description: 'Hacia un liderazgo con impacto más consciente y humano'
  # @meta_tags.set! canonical:

  erb :'services/landing/index', layout: :'layout/layout2022'
end

