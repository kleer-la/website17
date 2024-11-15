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
                  image: 'https://kleer-images.s3.sa-east-1.amazonaws.com/servicios_cover.webp'

  @path = 'servicios'
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

  return status 404 if service_area.nil?

  router_helper = RouterHelper.instance
  router_helper.alternate_route = '/agilidad-organizacional'

  show_service_area(service_area, 'servicios')
end

def show_service_area(service_area, path)
  @meta_tags.set! title: service_area.seo_title,
                  description: service_area.seo_description,
                  canonical: "/#{path}/#{service_area.slug}"

  @path = path
  @primary_color = service_area.primary_color
  @primary_font_color = service_area.primary_font_color
  @secondary_color = service_area.secondary_color
  @secondary_font_color = service_area.secondary_font_color

  brightness = calculate_brightness(@primary_color)
  @hover_color = brightness > 128 ? '#000000' : '#FFFFFF'

  erb :'services/landing_area/index', layout: :'layout/layout2022', locals: { service_area: service_area }
end

def calculate_brightness(hex_color)
  # Remove '#' if present
  hex_color = hex_color.gsub('#', '')

  # Convert hex to RGB
  r = hex_color[0..1].to_i(16)
  g = hex_color[2..3].to_i(16)
  b = hex_color[4..5].to_i(16)

  # Calculate perceived brightness
  # Using the formula: (R * 299 + G * 587 + B * 114) / 1000
  (r * 299 + g * 587 + b * 114) / 1000
end
