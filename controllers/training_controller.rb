require './lib/dt_helper'
require './lib/metatags'

require './lib/event_type'
require './lib/event'

require './controllers/event_helper'

REDIRECT = {
  '179-taller-del-tiempo-(online)' => '47-taller-del-tiempo'
}.freeze

def course_not_found_error
  I18n.t('event.not_found')
end

def event_type_from_qstring(event_type_id_with_name)
  event_type_id = event_type_id_with_name.split('-')[0]
  KeventerReader.instance.event_type(event_type_id, true) if valid_id?(event_type_id)
end

def tracking_mantain_or_default(utm_source, utm_campaign)
  if !utm_source.nil? && !utm_campaign.nil? && utm_source != '' && utm_campaign != ''
    "&utm_source=#{utm_source}&utm_campaign=#{utm_campaign}"
  else
    '&utm_source=kleer.la&utm_campaign=kleer.la'
  end
end

def coming_courses
  KeventerReader.instance.coming_commercial_events
end

get '/entrenamos/:country?' do |country|
  entrenamos_view(country)
end
get '/entrenamos' do
  entrenamos_view
end
def entrenamos_view(country = nil)
  if !country.nil? && country != 'todos' && country.length > 2
    status 404
  else
    @active_tab_entrenamos = 'active'
    meta_tags! title: 'Agenda de cursos online sobre Agilidad y Scrum'
    meta_tags! description: 'Capacitaciones sobre Facilitación, Lean, Kanban, Product Discovery, Agile Coaching, Retrospectivas, Liderazgo, Mejora continua, Gestión del tiempo y más.'

    @unique_countries = KeventerReader.instance.unique_countries_for_commercial_events
    @country = country || session[:filter_country] || 'todos'
    session[:filter_country] = @country
    erb :entrenamos
  end
end

get '/catalogo' do
  @active_tab_entrenamos = 'active'
  meta_tags! title: 'Capacitación empresarial en agilidad organizacional'
  meta_tags! description: 'Formación en agilidad para equipos: Scrum, Mejora continua, Lean, Product Discovery, Agile Coaching, Liderazgo, Facilitación, Comunicación Colaborativa, Kanban.'
  @categories = KeventerReader.instance.categories session[:locale]

  if session[:version] == 2022
    @coming_courses = if session[:locale] == 'es'
                        coming_courses
                      else
                        fake_event_from_catalog(KeventerReader.instance.categories)
                      end

    return erb :'training/index', layout: :'layout/layout2022'
  elsif session[:locale] == 'en'
    erb :catalogo_en
  else
    erb :catalogo
  end
end

# Nuevo dispatcher de evento/id -> busca el tipo de evento y va a esa View
get '/entrenamos/evento/:event_id_with_name' do
  event_id_with_name = params[:event_id_with_name]
  event_id = event_id_with_name.split('-')[0]
  @event = KeventerReader.instance.event(event_id, true) if valid_id?(event_id)

  if @event.nil?
    redirect_not_found_course
  else
    uri = "/cursos/#{@event.event_type.id}-#{@event.event_type.name}" # TODO: use slug

    redirect uri # , 301 # permanent redirect
  end
end

# Redirect
#  To /catalogo when
#  - event type not found
#  - event type deleted and canonical is missing (replaced for slug)
#  To canonical when
#  - event type deleted and canonical is present
def should_redirect(event_type)
  return unless event_type.nil? || event_type.deleted

  if event_type.nil? || event_type.canonical_slug == event_type.slug
    redirect_not_found_course
  else
    redirect uri event_type.canonical_url, 301 # permanent redirect
  end
end

def redirect_not_found_course
  session[:error_msg] = course_not_found_error
  flash.now[:alert] = course_not_found_error
  redirect(to('/catalogo'))
end

# Nueva (y simplificada) ruta para Tipos de Evento
get '/cursos/:event_type_id_with_name' do
  redirect_to = REDIRECT[params[:event_type_id_with_name]]
  unless redirect_to.nil?
    uri = "/cursos/#{redirect_to}"
    return redirect uri, 301 # permanent redirect = REACTIVAR CUANDO ESTE TODO LISTO!
  end

  @event_type = event_type_from_qstring params[:event_type_id_with_name]
  redirecting = should_redirect(@event_type)
  (return redirecting) unless redirecting.nil?

  @active_tab_entrenamos = 'active'

  @tracking_parameters = tracking_mantain_or_default(params[:utm_source], params[:utm_campaign])

  if @event_type.nil?
    redirect_not_found_course
  else
    # SEO (title, meta)
    meta_tags! title: @event_type.name
    meta_tags! description: @event_type.elevator_pitch
    meta_tags! canonical: @event_type.canonical_url

    if @event_type.categories.count.positive?
      # Podría tener más de una categoría, pero se toma el codename de la primera como la del catálogo
      @category = KeventerReader.instance.category @event_type.categories[0][1], session[:locale]
    end
    erb :event_type
  end
end

post '/cursos/:event_type_id/contact' do
  @event_type = event_type_from_qstring params[:event_type_id]
  p params unless @event_type.nil?
end

# Ruta antigua para Tipos de Evento (redirige a la nueva)
get '/categoria/:category_codename/cursos/:event_type_id_with_name' do
  redirect to "/cursos/#{params[:event_type_id_with_name]}", 301
end

get '/entrenamos/evento/:event_id_with_name/entrenador/remote' do
  event_id_with_name = params[:event_id_with_name]

  event_id = event_id_with_name.split('-')[0]
  @event = KeventerReader.instance.event(event_id, false) if valid_id?(event_id)

  if @event.nil?
    session[:error_msg] = course_not_found_error
    erb :error_404_remote_to_calendar, layout: :layout_empty
  else
    erb :trainer_remote, layout: :layout_empty
  end
end

get '/entrenamos/evento/:event_id_with_name/remote' do
  event_id_with_name = params[:event_id_with_name]

  event_id = event_id_with_name.split('-')[0]
  @event = KeventerReader.instance.event(event_id, false) if valid_id?(event_id)

  if @event.nil?
    session[:error_msg] = course_not_found_error
    erb :error_404_remote_to_calendar, layout: :layout_empty
  else
    erb :event_remote, layout: :layout_empty
  end
end

get '/entrenamos/evento/:event_id_with_name/registration' do
  event_id_with_name = params[:event_id_with_name]

  event_id = event_id_with_name.split('-')[0]
  @event = KeventerReader.instance.event(event_id, false) if valid_id?(event_id)

  if @event.nil?
    session[:error_msg] = course_not_found_error
    erb :error_404_remote_to_calendar, layout: :layout_empty
  else
    erb :event_remote_registration, layout: :layout_empty
  end
end

# JSON ====================

get '/entrenamos/eventos/proximos' do
  content_type :json
  DTHelper.to_dt_event_array_json(KeventerReader.instance.coming_commercial_events, true,
                                  'cursos')
end

get '/entrenamos/eventos/proximos/:amount' do
  content_type :json
  amount = params[:amount]
  amount = amount.to_i unless amount.nil?
  DTHelper.to_dt_event_array_json(KeventerReader.instance.coming_commercial_events, true,
                                  'cursos', I18n, session[:locale], amount, false)
end

get '/entrenamos/eventos/pais/:country_iso_code' do
  content_type :json
  country_iso_code = params[:country_iso_code]
  country_iso_code = 'todos' unless valid_country_iso_code?(country_iso_code, 'cursos')
  session[:filter_country] = country_iso_code
  DTHelper.to_dt_event_array_json(
    KeventerReader.instance.commercial_events_by_country(country_iso_code), false, 'cursos', I18n, session[:locale]
  )
end
