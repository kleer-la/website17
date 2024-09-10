require './lib/models/service_area_v3'

get '/agilidad-organizacional' do
  return redirect('/es/servicios', 301) if session[:locale] == 'es'

  @active_tab_coaching = 'active'
  @meta_tags.set! title: t('meta_tag.business-agility.title'),
                  description: t('meta_tag.business-agility.description'),
                  canonical: t('meta_tag.business-agility.canonical').to_s

  erb :'business_agility/index', layout: :'layout/layout2022'
end

get %r{/servicios/?} do
  redirect to("#{session[:locale]}/agilidad-organizacional"), 301 if session[:locale] == 'en'

  @areas = ServiceAreaV3.create_list_keventer

  @meta_tags.set! title: t('meta_tag.services.title'),
                  description: t('meta_tag.services.description'),
                  canonical: t('meta_tag.services.canonical').to_s,
                  image: 'https://kleer-images.s3.sa-east-1.amazonaws.com/servicios_cover.png'

  router_helper = RouterHelper.instance
  router_helper.alternate_route = '/agilidad-organizacional'

  erb :'services/landing_page/index', layout: :'layout/layout2022'
end

get '/servicios/:slug' do
  redirect to("#{session[:locale]}/agilidad-organizacional"), 301 if session[:locale] == 'en'

  service_area = ServiceAreaV3.create_keventer params[:slug]
  return status 404 if service_area.nil?

  @service_slug = if service_area.slug != params[:slug]
                    params[:slug]
                  else
                    'none'
                  end

  @primary_color = service_area.primary_color
  @secondary_color = service_area.secondary_color

  return status 404 if service_area.nil?

  @meta_tags.set! title: service_area.seo_title,
                  description: service_area.seo_description,
                  canonical: "/servicios/#{service_area.slug}"

  router_helper = RouterHelper.instance
  router_helper.alternate_route = '/agilidad-organizacional'

  erb :'services/landing_area/index', layout: :'layout/layout2022', locals: { service_area: service_area }
end
