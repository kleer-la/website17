require './lib/models/service_model'
require './lib/models/service_area'
require './lib/readers/local_reader'

get '/servicios' do
  begin

    if session[:locale] == 'en'
      redirect to("#{session[:locale]}/agilidad-organizacional"), 301
    end

    @services = Service.load_list

    @meta_tags.set! title: t('meta_tag.business-agility.title'),
                    description: t('meta_tag.business-agility.description'),
                    canonical: "#{t('meta_tag.business-agility.canonical')}"

    router_helper = RouterHelper.instance
    router_helper.alternate_route = "/agilidad-organizacional"

    erb :'services/index', layout: :'layout/layout2022'
  rescue
    status 500
  end
end

get '/servicios-v3' do
  @areas = ServiceArea.create_list_keventer

  puts @areas.inspect
  erb :'services/landing_page/index', layout: :'layout/layout2022'
end

get '/servicios/:service_id' do
  begin
    if session[:locale] == 'en'
      redirect to("#{session[:locale]}/agilidad-organizacional"), 301
    end

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
  rescue
    status 500
  end
end

