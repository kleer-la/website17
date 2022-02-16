require './lib/dt_helper'
require './lib/event_type'
require './lib/metatags'

REDIRECT = {
  '179-taller-del-tiempo-(online)' => '47-taller-del-tiempo'
}

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
    @page_title = 'Agenda de cursos online sobre Agilidad y Scrum'
    @meta_description = 'Capacitaciones sobre Facilitación, Lean, Kanban, Product Discovery, Agile Coaching, Retrospectivas, Liderazgo, Mejora continua, Gestión del tiempo y más.'

    @unique_countries = KeventerReader.instance.unique_countries_for_commercial_events
    @country = country || session[:filter_country] || 'todos'
    session[:filter_country] = @country
    erb :entrenamos
  end
end

get '/catalogo' do
  @active_tab_entrenamos = 'active'
  @page_title = 'Capacitación empresarial en agilidad organizacional'
  @meta_description = 'Formación en agilidad para equipos: Scrum, Mejora continua, Lean, Product Discovery, Agile Coaching, Liderazgo, Facilitación, Comunicación Colaborativa, Kanban.'
  @categories = KeventerReader.instance.categories session[:locale]
  erb :catalogo
end

# Nuevo dispatcher de evento/id -> busca el tipo de evento y va a esa View
get '/entrenamos/evento/:event_id_with_name' do
  event_id_with_name = params[:event_id_with_name]
  event_id = event_id_with_name.split('-')[0]
  @event = KeventerReader.instance.event(event_id, true) if valid_id?(event_id)

  if @event.nil?
    flash.now[:error] = course_not_found_error
    redirect to('/entrenamos')
  else
    uri = "/cursos/#{@event.event_type.id}-#{@event.event_type.name}"

    redirect uri # , 301 # permanent redirect
  end
end
# Nueva (y simplificada) ruta para Tipos de Evento
get '/cursos/:event_type_id_with_name' do
  redirect_to = REDIRECT[params[:event_type_id_with_name]]
  unless redirect_to.nil?
    uri = "/cursos/#{redirect_to}"

    return redirect uri , 301 # permanent redirect = REACTIVAR CUANDO ESTE TODO LISTO!
  end

  @active_tab_entrenamos = 'active'

  @event_type = event_type_from_qstring params[:event_type_id_with_name]
  @tracking_parameters = tracking_mantain_or_default(params[:utm_source], params[:utm_campaign])

  if @event_type.nil?
    flash.now[:error] = course_not_found_error
    erb :error_404_to_calendar
  else
    # SEO (title, meta)
    @page_title = "Kleer - #{@event_type.name}"
    @meta_description = @event_type.elevator_pitch
    # problema con url certified-scrum-master-(csm)
    # MetaTags::meta_tags! canonical: @event_type.canonical_url
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
    @error = course_not_found_error
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
    @error = course_not_found_error
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
    @error = course_not_found_error
    erb :error_404_remote_to_calendar, layout: :layout_empty
  else
    erb :event_remote_registration, layout: :layout_empty
  end
end
