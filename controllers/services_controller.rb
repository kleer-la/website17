require './lib/models/service_model'
require './lib/readers/local_reader'

get '/servicios/:service_id' do
  service_id = params[:service_id]

  reader = LocalReader.new
  @event_type = reader.load_service(service_id)

  @meta_tags.set! title: @event_type.name,
                  description: @event_type.elevator_pitch,
                  canonical: "/servicios#{@event_type.canonical_url}"


  erb :'services/landing/index', layout: :'layout/layout2022'
end

