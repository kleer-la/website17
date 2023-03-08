require './lib/dt_helper'
require './lib/metatags'
require './lib/academy_courses'
require './lib/event_type'
require './lib/event'
require './lib/keventer_helper'

require './controllers/event_helper'

#TODO redirect
REDIRECT = {
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

def tracking_mantain_or_default(utm_source, utm_campaign)
  if !utm_source.nil? && !utm_campaign.nil? && utm_source != '' && utm_campaign != ''
    "&utm_source=#{utm_source}&utm_campaign=#{utm_campaign}"
  else
    '&utm_source=kleer.la&utm_campaign=kleer.la'
  end
end

def coming_courses
  Event.create_keventer_json
  # KeventerReader.instance.coming_commercial_events
end

def load_categories(lang)
  # KeventerReader.instance.categories lang
  Category.create_keventer_json lang
end

get '/agenda' do
  @meta_tags.set! title: t('meta_tag.agenda.title'),
                  description: t('meta_tag.agenda.description'),
                  canonical: "#{t('meta_tag.agenda.canonical')}"

  # @events = KeventerReader.instance.catalog_events()
  @events = Event.create_keventer_json
  erb :'training/agenda/index', layout: :'layout/layout2022'
end

get '/catalogo' do
  @active_tab_entrenamos = 'active'
  @meta_tags.set! title: t('meta_tag.catalog.title'),
                  description: t('meta_tag.catalog.description'),
                  canonical: "#{t('meta_tag.catalog.canonical')}"
  @categories = load_categories session[:locale]
  @academy = AcademyCourses.new.load.all

  @events = KeventerReader.instance.catalog_events()

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

def redirect_not_found_course
  session[:error_msg] = course_not_found_error
  flash.now[:alert] = course_not_found_error
  redirect(to('/catalogo'))
end

#TODO
# Nueva (y simplificada) ruta para Tipos de Evento
get '/cursos/:event_type_id_with_name' do

  @event_type = event_type_from_json params[:event_type_id_with_name]
  #TODO depracated?
  #   @event_type = event_type_from_qstring params[:event_type_id_with_name]
  #   @testimonies = KeventerReader.instance.testimonies(params[:event_type_id_with_name].split('-')[0])

  @active_tab_entrenamos = 'active'

  @tracking_parameters = tracking_mantain_or_default(params[:utm_source], params[:utm_campaign])

  if @event_type.nil?
    redirect_not_found_course
  else
    redirecting = @event_type.redirect_to(params[:event_type_id_with_name])
    unless redirecting.nil?
      return redirect_not_found_course if redirecting == ''
      redirect to(redirecting), 301
    end

    # SEO (title, meta)
    @meta_tags.set! title: @event_type.name
    @meta_tags.set! description: @event_type.elevator_pitch
    @meta_tags.set! canonical: @event_type.canonical_url

    if @event_type.categories.count.positive?
      # Podría tener más de una categoría, pero se toma el codename de la primera como la del catálogo
      @category = KeventerReader.instance.category @event_type.categories[0][1], session[:locale]
    end

    @related_courses = get_related_event_types(@event_type.categories[0], @event_type.id , 4)

    erb :'training/landing_course/index', layout: :'layout/layout2022'
  end
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

