require './lib/metatags'
require './lib/academy_courses'
require './lib/category'
require './lib/event_type'
require './lib/event'
require './lib/keventer_helper'
require './lib/models/catalog'

REDIRECT = {
  'entrenamos/eventos/proximos' => 'agenda',
  'entrenamos/eventos/proximos/:amount' => 'agenda',
  'entrenamos/eventos/pais/:country_iso_code' => 'agenda',
  'entrenamos/:id' => 'agenda',
  'entrenamos' => 'agenda',
  'entrenamos/' => 'agenda',
  'entrenamos/evento/:event_id_with_name' => nil,
  'entrenamos/evento/:event_id_with_name/registration' => nil,
  'entrenamos/evento/:event_id_with_name/remote' => nil,
  'entrenamos/evento/:event_id_with_name/entrenador/remote' => nil,
  'categoria/:category_codename' => 'catalogo',
  'categoria/:category_codename/' => 'catalogo',
  'comunidad/evento/337-equipos-mas-productivos-buenos-aires' => 'cursos/339-taller-de-comunicacion-colaborativa'
  # 'comunidad/evento/:event_id_with_name' => '???',   #TODO: convert event ID to event Type
}.freeze

REDIRECT.each do |uris|
  get "/#{uris[0]}" do
    return(redirect_not_found_course) if uris[1].nil?

    redirect "/#{session[:locale]}/#{uris[1]}" # , 301
  end
end

def course_not_found_error
  I18n.t('event.not_found')
end

def redirect_not_found_course
  session[:error_msg] = course_not_found_error
  flash.now[:alert] = course_not_found_error
  lang = session[:locale]
  catalog_path = RouterHelper.translate_path('catalogo', lang)
  redirect(to("/#{lang}/#{catalog_path}"))
end

def event_type_from_json(event_type_id_with_name)
  event_type_id = event_type_id_with_name.split('-')[0]
  EventType.create_keventer_json(event_type_id) if valid_id?(event_type_id)
end


def coming_courses
  Event.create_keventer_json
end

def load_categories(lang)
  Category.create_keventer_json lang
end

get %r{/(agenda|schedule)/?} do
  page = Page.load_from_keventer(session[:locale], 'agenda')
  @meta_tags.set! title: page.seo_title || t('meta_tag.agenda.title'),
                  description: page.seo_description || t('meta_tag.agenda.description'),
                  canonical: page.canonical || t('meta_tag.agenda.canonical'),
                  alternate_paths: { es: '/agenda', en: '/schedule' }
  @meta_tags.set! image: page.cover unless page.cover.nil?

  @events = Event.create_keventer_json

  router_helper = RouterHelper.instance
  router_helper.alternate_route = RouterHelper.alternate_path('agenda', session[:locale])

  erb :'training/agenda/index', layout: :'layout/layout2022'
end

get %r{/(catalogo|catalog)/?} do
  page = Page.load_from_keventer(session[:locale], 'catalogo')
  @meta_tags.set! title: page.seo_title || t('meta_tag.catalog.title'),
                  description: page.seo_description || t('meta_tag.catalog.description'),
                  canonical: page.canonical || t('meta_tag.catalog.canonical')
  @meta_tags.set! image: page.cover unless page.cover.nil?
  @active_tab_entrenamos = 'active'
  @categories = load_categories session[:locale]
  @events = Catalog.create_keventer_json

  router_helper = RouterHelper.instance
  router_helper.alternate_route = RouterHelper.alternate_path('catalogo', session[:locale])
  erb :'training/catalog/index', layout: :'layout/layout2022'
end

# Nueva (y simplificada) ruta para Tipos de Evento
get %r{/(cursos|courses)/([^/]+)} do |lang_path, event_type_id_with_name|
  @event_type = event_type_from_json event_type_id_with_name
  @active_tab_entrenamos = 'active'

  if @event_type.nil?
    redirect_not_found_course
  else
    if session[:locale] != @event_type.lang
      lang = session[:locale]
      catalog_path = RouterHelper.translate_path('catalogo', lang)
      redirect to("/#{lang}/#{catalog_path}"), 301
    end

    redirecting = @event_type.redirect_to(event_type_id_with_name)
    unless redirecting.nil?
      return redirect_not_found_course if redirecting == ''

      redirect to(redirecting), 301
    end

    # SEO (title, meta)
    @meta_tags.set! title: @event_type.seo_title || @event_type.name,
                    description: @event_type.elevator_pitch,
                    canonical: @event_type.canonical_url,
                    noindex: @event_type.noindex,
                    image: @event_type.cover

    @extra_script = @event_type.extra_script

    if @event_type.categories.count.positive?
      # Podría tener más de una categoría, pero se toma el codename de la primera como la del catálogo
      @category = @event_type.categories[0]
    end

    router_helper = RouterHelper.instance
    router_helper.alternate_route = RouterHelper.alternate_path('catalogo', session[:locale])

    erb :'training/landing_course/index', layout: :'layout/layout2022'
  end
end

# Ruta antigua para Tipos de Evento (redirige a la nueva)
get '/categoria/:category_codename/cursos/:event_type_id_with_name' do
  redirect to "/cursos/#{params[:event_type_id_with_name]}", 301
end

# <%= erb :'component/sections/recommended', locals: { recommended: @event_type.recommended, title: t('recommended.title')  }%>
get '/formacion/:slug*?' do
  is_preview_mode = request.path_info.end_with?('/preview')
  service_area = ServiceAreaV3.create_keventer(params[:slug], is_preview_mode)
  return status 404 if service_area.nil?

  lang = session[:locale] || 'es'

  # Check if service area language matches the requested language
  if service_area.lang != lang
    redirect to("/#{lang}/catalogo"), 301
  end

  @service_slug = if service_area.slug != params[:slug]
                    params[:slug]
                  else
                    'none'
                  end
  return status 404 if service_area.nil?

  @is_training_program = true

  show_service_area(service_area, 'formacion')
end

get '/training/:slug*?' do
  is_preview_mode = request.path_info.end_with?('/preview')
  service_area = ServiceAreaV3.create_keventer(params[:slug], is_preview_mode)
  return status 404 if service_area.nil?

  lang = session[:locale] || 'en'

  # Check if service area language matches the requested language
  if service_area.lang != lang
    redirect to("/#{lang}/catalog"), 301
  end

  @service_slug = if service_area.slug != params[:slug]
                    params[:slug]
                  else
                    'none'
                  end
  return status 404 if service_area.nil?

  @is_training_program = true

  show_service_area(service_area, 'training')
end
