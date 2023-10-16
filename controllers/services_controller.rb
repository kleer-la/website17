require './lib/models/service_model'
require './lib/readers/local_reader'

get '/servicios' do
  # begin
    @services = Service.load_list

    erb :'services/index', layout: :'layout/layout2022'
  # rescue
  #   status 500
  # end
end

get '/servicios/:service_id' do
  # begin
    service_id = params[:service_id]

    reader = LocalReader.new
    @service = reader.load_service(service_id)

    if @service.nil?
      return status 404
    end

    @meta_tags.set! title: @service.seo_title || @service.name,
                    description: @service.elevator_pitch,
                    canonical: "/servicios#{@service.canonical_url}"

    router_helper = RouterHelper.instance
    router_helper.alternate_route = "/agilidad-organizacional"


    erb :'services/landing/index', layout: :'layout/layout2022'
  # rescue
  #   status 500
  # end
end

