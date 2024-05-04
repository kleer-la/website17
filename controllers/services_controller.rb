require './lib/models/service_model'
# require './lib/models/service_area'
# require './lib/readers/local_reader'
require './lib/models/service_area_v3'

get '/servicios' do
  begin

    if session[:locale] == 'en'
      redirect to("#{session[:locale]}/agilidad-organizacional"), 301
    end

    # @areas = Service.load_list
    @areas = ServiceAreaV3.create_list_keventer

    @meta_tags.set! title: t('meta_tag.business-agility.title'),
                    description: t('meta_tag.business-agility.description'),
                    canonical: "#{t('meta_tag.business-agility.canonical')}"

    router_helper = RouterHelper.instance
    router_helper.alternate_route = "/agilidad-organizacional"

    erb :'services/landing_page/index', layout: :'layout/layout2022'

  rescue
    status 500
  end
end

# get '/servicios-v3' do
#   # @areas = Service.load_list
#    # @areas = ServiceArea.create_list_keventer
#   @areas = ServiceAreaV3.create_list_keventer

#   erb :'services/landing_page/index', layout: :'layout/layout2022'
# end

# get '/servicios/:service_id' do
#   begin
#     if session[:locale] == 'en'
#       redirect to("#{session[:locale]}/agilidad-organizacional"), 301
#     end

#     service_id = params[:service_id]

#     reader = LocalReader.new
#     @service = reader.load_service(service_id)

#     if @service.nil?
#       return status 404
#     end

#     @meta_tags.set! title: @service.seo_title || @service.name,
#                     description: @service.elevator_pitch,
#                     canonical: "/servicios#{@service.canonical_url}"

#     router_helper = RouterHelper.instance
#     router_helper.alternate_route = "/agilidad-organizacional"

#     erb :'services/landing/index', layout: :'layout/layout2022'
#   rescue
#     status 500
#   end
# end

# get '/servicios-v3/:area_id' do
#   load_area_service(params[:area_id])
# end

get '/servicios-v3/:slug' do
  begin
    if session[:locale] == 'en'
      redirect to("#{session[:locale]}/agilidad-organizacional"), 301
    end

    service_area = ServiceAreaV3.create_keventer params[:slug]
    if service_area.nil?
      return status 404
    end

    if service_area.slug != params[:slug]
      @service_slug = params[:slug]
    else
      @service_slug = 'none'
    end

    @primary_color = service_area.primary_color
    @secondary_color = service_area.secondary_color

    if service_area.nil?
      return status 404
    end

    @meta_tags.set! title: service_area.seo_title,
                    description: service_area.seo_description

    router_helper = RouterHelper.instance
    router_helper.alternate_route = "/agilidad-organizacional"

    erb :'services/landing_area/index', layout: :'layout/layout2022', locals: {service_area: service_area}
  # rescue
  #   status 500
  end
end



