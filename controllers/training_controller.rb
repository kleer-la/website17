require './lib/dt_helper'
require './lib/metatags'
require './lib/academy_courses'
require './lib/event_type'
require './lib/event'
require 'ruby-prof'


require './controllers/event_helper'

#TODO redirect
REDIRECT = {
  '179-taller-del-tiempo-(online)' => '47-taller-del-tiempo',
  'entrenamos/todos' => 'agenda',
  'entrenamos' => 'agenda'
}.freeze

REDIRECT.each do |uris|
  get '/'+uris[0] do
     redirect '/'+uris[1] #, 301
  end
end

def course_not_found_error
  I18n.t('event.not_found')
end

def event_type_from_json(event_type_id_with_name)
  event_type_id = event_type_id_with_name.split('-')[0]
  EventType.create_keventer_json(event_type_id) if valid_id?(event_type_id)
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

get '/agenda' do

  RubyProf.start
  RubyProf.measure_mode = RubyProf::MEMORY
  @meta_tags.set! title: 'Agenda de cursos online sobre Agilidad y Scrum'
  @meta_tags.set! description: 'Capacitaciones sobre Facilitación, Lean, Kanban, Product Discovery, Agile Coaching, Retrospectivas, Liderazgo, Mejora continua, Gestión del tiempo y más.'

  @events = KeventerReader.instance.catalog_events()

  result = RubyProf.stop

  printer = RubyProf::FlatPrinter.new(result)
  printer.print(STDOUT)
  erb :'training/agenda/index', layout: :'layout/layout2022'
end

get('/catalogo2022') { session[:version] = 2022; catalog }
get('/catalogo') {  catalog }

def catalog
  @active_tab_entrenamos = 'active'
  @meta_tags.set! title: 'Capacitación empresarial en agilidad organizacional'
  @meta_tags.set! description: 'Formación en agilidad para equipos: Scrum, Mejora continua, Lean, Product Discovery, Agile Coaching, Liderazgo, Facilitación, Comunicación Colaborativa, Kanban.'
  @categories = KeventerReader.instance.categories session[:locale]
  @academy = AcademyCourses.new.load.all

  @events = KeventerReader.instance.catalog_events()

  @coming_courses = if session[:locale] == 'es'
                      KeventerReader.instance.coming_commercial_events(Date.today, 10)
                    else
                      fake_event_from_catalog(KeventerReader.instance.categories)
                    end


  erb :'training/index', layout: :'layout/layout2022'
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

#TODO
# Nueva (y simplificada) ruta para Tipos de Evento
get '/cursos/:event_type_id_with_name' do
  from_json = !(params['json'].to_s.length > 0)

  redirect_to = REDIRECT[params[:event_type_id_with_name]]
  unless redirect_to.nil?
    uri = "/cursos/#{redirect_to}"
    return redirect uri, 301 # permanent redirect = REACTIVAR CUANDO ESTE TODO LISTO!
  end

  if from_json
    @event_type = event_type_from_json params[:event_type_id_with_name]
    @testimonies = KeventerReader.instance.testimonies(params[:event_type_id_with_name].split('-')[0]) # TODO
  else
    @event_type = event_type_from_qstring params[:event_type_id_with_name]
    @testimonies = KeventerReader.instance.testimonies(params[:event_type_id_with_name].split('-')[0])
  end

  redirecting = should_redirect(@event_type)
  (return redirecting) unless redirecting.nil?

  @active_tab_entrenamos = 'active'

  @tracking_parameters = tracking_mantain_or_default(params[:utm_source], params[:utm_campaign])

  if @event_type.nil?
    redirect_not_found_course
  else
    # SEO (title, meta)
    @meta_tags.set! title: @event_type.name
    @meta_tags.set! description: @event_type.elevator_pitch
    @meta_tags.set! canonical: @event_type.canonical_url

    if @event_type.categories.count.positive?
      # Podría tener más de una categoría, pero se toma el codename de la primera como la del catálogo
      @category = KeventerReader.instance.category @event_type.categories[0][1], session[:locale]
    end

    # unless @event_type.is_new_version
    #   return erb :event_type
    # end

    erb :'training/landing_course/index', layout: :'layout/layout2022'
  end
end

#TODO
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
  data = DTHelper.to_dt_event_array_json(
    KeventerReader.instance.commercial_events_by_country(country_iso_code), false, 'cursos', I18n, session[:locale]
  )
  data
end

