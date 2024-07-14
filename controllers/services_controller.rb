require './lib/models/service_area_v3'

get %r{/servicios/?} do
    if session[:locale] == 'en'
      redirect to("#{session[:locale]}/agilidad-organizacional"), 301
    end

    @areas = ServiceAreaV3.create_list_keventer

    @meta_tags.set! title: t('meta_tag.services.title'),
                    description: t('meta_tag.services.description'),
                    canonical: "#{t('meta_tag.services.canonical')}"

    router_helper = RouterHelper.instance
    router_helper.alternate_route = "/agilidad-organizacional"

    erb :'services/landing_page/index', layout: :'layout/layout2022'
end

get '/servicios/:slug' do
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
                  description: service_area.seo_description,
                  canonical: "/servicios/#{service_area.slug}"

  router_helper = RouterHelper.instance
  router_helper.alternate_route = "/agilidad-organizacional"

  erb :'services/landing_area/index', layout: :'layout/layout2022', locals: {service_area: service_area}
end
