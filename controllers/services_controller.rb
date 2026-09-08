require './lib/models/service_area_v3'

get '/agilidad-organizacional' do
  return redirect('/es/servicios', 301) if session[:locale] == 'es'

  @active_tab_coaching = 'active'
  @meta_tags.set! title: t('meta_tag.business-agility.title'),
                  description: t('meta_tag.business-agility.description'),
                  canonical: t('meta_tag.business-agility.canonical').to_s

  render_page :'business_agility/index'
end

get %r{/(servicios|services)/?} do
  # redirect to("#{session[:locale]}/agilidad-organizacional"), 301 if session[:locale] == 'en'
  @page = Page.load_from_keventer(session[:locale], 'services-landing')

  @areas = ServiceAreaV3.try_create_list_keventer
                        .filter { |a| a.lang == session[:locale] }

  @meta_tags.set! title: @page.seo_title || t('meta_tag.services.title'),
                  description: @page.seo_description || t('meta_tag.services.description'),
                  canonical: @page.canonical || t('meta_tag.services.canonical').to_s,
                  image: cdn('servicios_cover.webp'),
                  alternate_paths: { es: '/servicios', en: '/services' }

  @path = 'servicios'
  router_helper = RouterHelper.instance
  router_helper.alternate_route = RouterHelper.alternate_path('servicios', session[:locale])

  render_page :'services/landing_page/index'
end

get %r{/(?:servicios|services)/([a-z0-9_-]+)/([a-z0-9_-]+)} do |area_slug, service_slug|
  @is_training_program = false
  @page = Page.load_from_keventer(session[:locale], 'service-area')

  # `pass`, not 404: this pattern also covers paths that later routes claim by
  # name — the redirects for the old adopcion-ia URLs, for instance, never fired
  # because this route answered 404 first and nothing downstream got a turn.
  service_area = ServiceAreaV3.create_keventer area_slug
  pass if service_area.nil?
  pass if service_area.is_training_program

  service = service_area.services.find { |s| s.slug == service_slug }
  pass if service.nil?

  router_helper = RouterHelper.instance
  router_helper.alternate_route = RouterHelper.alternate_path('servicios', session[:locale])

  show_service(service_area, service, section_path)
end

get %r{/(?:servicios|services)/([a-z0-9_-]+)} do |slug|
  @is_training_program = false
  @page = Page.load_from_keventer(session[:locale], 'service-area')

  service_area = ServiceAreaV3.create_keventer slug
  return status 404 if service_area.nil?

  redirect to(area_url(service_area, slug)), 301 if service_area.is_training_program

  router_helper = RouterHelper.instance
  router_helper.alternate_route = RouterHelper.alternate_path('servicios', session[:locale])

  show_service_area(service_area, section_path)
end

# The services routes answer under /servicios and /services alike, so the
# segment has to come from the language, not from the pattern.
def section_path
  RouterHelper.translate_path('servicios', session[:locale] || 'es')
end

# An area that does not declare a language is Spanish, which is what the
# routes already assume.
def area_lang(service_area)
  (service_area.lang.to_s.empty? ? 'es' : service_area.lang).to_sym
end

def show_service_area(service_area, path)
  # An area exists in one language: the English ones are separate records with
  # their own slugs, and nothing links them to the Spanish ones. Naming both
  # built the alternate by reusing this slug under the other prefix — a page
  # that is this same area with the other chrome, not its translation.
  @meta_tags.set! title: service_area.seo_title,
                  description: service_area.seo_description,
                  canonical: "/#{path}/#{service_area.slug}",
                  hreflang: [area_lang(service_area)]

  @path = path
  @has_consultants = service_area_has_consultants?(service_area.slug)
  set_area_colors(service_area)

  render_page :'services/landing_area/index', locals: { service_area: service_area }
end

def show_service(service_area, service, path)
  @meta_tags.set! title: service.seo_title || "#{service.name} - #{service_area.name}",
                  description: service.seo_description || service.subtitle,
                  canonical: "/#{path}/#{service_area.slug}/#{service.slug}",
                  hreflang: [area_lang(service_area)]

  @path = path
  @has_consultants = service_area_has_consultants?(service_area.slug)
  set_area_colors(service_area)

  @json_ld = service_json_ld(service, service_area)

  render_page :'services/landing_service/index',
              locals: { service_area: service_area, service: service }
end

def set_area_colors(service_area)
  @primary_color = service_area.primary_color
  @primary_font_color = service_area.primary_font_color
  @secondary_color = service_area.secondary_color
  @secondary_font_color = service_area.secondary_font_color

  brightness = calculate_brightness(@primary_color)
  @hover_color = brightness > 128 ? '#000000' : '#FFFFFF'
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
