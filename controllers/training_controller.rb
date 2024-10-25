require './lib/metatags'
require './lib/academy_courses'
require './lib/category'
require './lib/event_type'
require './lib/event'
require './lib/keventer_helper'
require './lib/models/catalog'

require './controllers/event_helper'

REDIRECT = {
  'entrenamos/eventos/proximos' => 'agenda',
  'entrenamos/eventos/proximos/:amount' => 'agenda',
  'entrenamos/eventos/pais/:country_iso_code' => 'agenda',
  'entrenamos/:id' => 'agenda',
  'entrenamos' => 'agenda',
  'entrenamos/evento/:event_id_with_name' => nil,
  'entrenamos/evento/:event_id_with_name/registration' => nil,
  'entrenamos/evento/:event_id_with_name/remote' => nil,
  'entrenamos/evento/:event_id_with_name/entrenador/remote' => nil,
  'categoria/:category_codename' => 'catalogo',
  'categoria/:category_codename/' => 'catalogo'
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
  redirect(to("/#{session[:locale]}/catalogo"))
end

def event_type_from_json(event_type_id_with_name)
  event_type_id = event_type_id_with_name.split('-')[0]
  EventType.create_keventer_json(event_type_id) if valid_id?(event_type_id)
end

def tracking_mantain_or_default(utm_source, utm_campaign)
  if !utm_source.nil? && !utm_campaign.nil? && utm_source != '' && utm_campaign != ''
    "&utm_source=#{utm_source}&utm_campaign=#{utm_campaign}"
  else
    '&utm_source=kleer.la&utm_campaign=kleer.la'
  end
end

def coming_courses
  Event.create_keventer_json
end

def load_categories(lang)
  Category.create_keventer_json lang
end

get '/agenda' do
  page = Page.load_from_keventer(session[:locale], 'agenda')
  @meta_tags.set! title: page.seo_title || t('meta_tag.agenda.title'),
                  description: page.seo_description || t('meta_tag.agenda.description'),
                  canonical: page.canonical || t('meta_tag.agenda.canonical')
  @meta_tags.set! image: page.cover unless page.cover.nil?

  @events = Event.create_keventer_json

  router_helper = RouterHelper.instance
  router_helper.alternate_route = '/catalogo'

  erb :'training/agenda/index', layout: :'layout/layout2022'
end

get '/catalogo' do
  page = Page.load_from_keventer(session[:locale], 'catalogo')
  @meta_tags.set! title: page.seo_title || t('meta_tag.catalog.title'),
                  description: page.seo_description || t('meta_tag.catalog.description'),
                  canonical: page.canonical || t('meta_tag.catalog.canonical')
  @meta_tags.set! image: page.cover unless page.cover.nil?
  @active_tab_entrenamos = 'active'
  @categories = load_categories session[:locale]
  @events = Catalog.create_keventer_json

  router_helper = RouterHelper.instance
  router_helper.alternate_route = '/catalogo'

  erb :'training/catalog/index', layout: :'layout/layout2022'
end

# Nueva (y simplificada) ruta para Tipos de Evento
get '/cursos/:event_type_id_with_name' do
  @event_type = event_type_from_json params[:event_type_id_with_name]
  @active_tab_entrenamos = 'active'
  @tracking_parameters = tracking_mantain_or_default(params[:utm_source], params[:utm_campaign])

  if @event_type.nil?
    redirect_not_found_course
  else
    redirect to("#{session[:locale]}/catalogo"), 301 if session[:locale] != @event_type.lang

    redirecting = @event_type.redirect_to(params[:event_type_id_with_name])
    unless redirecting.nil?
      return redirect_not_found_course if redirecting == ''

      redirect to(redirecting), 301
    end

    # SEO (title, meta)
    @meta_tags.set! title: @event_type.name,
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
    router_helper.alternate_route = '/catalogo'

    erb :'training/landing_course/index', layout: :'layout/layout2022'
  end
end

# Ruta antigua para Tipos de Evento (redirige a la nueva)
get '/categoria/:category_codename/cursos/:event_type_id_with_name' do
  redirect to "/cursos/#{params[:event_type_id_with_name]}", 301
end

# <%= erb :'component/sections/recommended', locals: { recommended: @event_type.recommended, title: t('recommended.title')  }%>
get '/formacion/:slug' do
  service_area = ServiceAreaV3.create_keventer params[:slug]
  return status 404 if service_area.nil?

  @service_slug = if service_area.slug != params[:slug]
                    params[:slug]
                  else
                    'none'
                  end
  return status 404 if service_area.nil?

  @primary_color = service_area.primary_color
  @secondary_color = service_area.secondary_color

  @meta_tags.set! title: service_area.seo_title,
                  description: service_area.seo_description,
                  canonical: "/formacion/#{service_area.slug}"
  @is_training_program = true
  erb :'services/landing_area/index', layout: :'layout/layout2022',
                                      locals: { service_area: service_area }
end
