require './lib/dt_helper'
require './lib/metatags'
require './lib/academy_courses'
require './lib/event_type'
require './lib/event'

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
  @meta_tags.set! title: 'Agenda de cursos online sobre Agilidad y Scrum'
  @meta_tags.set! description: 'Capacitaciones sobre Facilitación, Lean, Kanban, Product Discovery, Agile Coaching, Retrospectivas, Liderazgo, Mejora continua, Gestión del tiempo y más.'

  @events = KeventerReader.instance.catalog_events()
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

class Service
  attr_accessor :public_editions, :name, :subtitle, :description, :side_image, :takeaways, 
                :recipients, :program, :brochure,
                :cta
  def initialize()
    @public_editions = []
    @side_image = ''
  end
end

#TODO move to services controller
get '/servicios/desarrollo-liderazgo-agil' do
  @meta_tags.set! title: 'Programa de Desarrollo del Liderazgo Ágil'
  @meta_tags.set! description: 'Hacia un liderazgo con impacto más consciente y humano'
  # @meta_tags.set! canonical: 
  @event_type = Service.new
  @event_type.name = 'Programa de Desarrollo del Liderazgo Ágil'
  @event_type.subtitle = 'Hacia un liderazgo con impacto más consciente y humano'
  @event_type.description = 
'''
El nivel de agilidad que una organización sea capaz de alcanzar está acotado por el nivel de
agilidad colectiva de quienes la lideran.
### ¿Por qué desarrollar el liderazgo ágil?

Con la transformación digital de las organizaciones, emerge el desafío clave de la evolución de su management hacia un liderazgo ágil. Se vuelve crítico evolucionar el modelo de liderazgo colectivo, lo que en última instancia, impactará en la cultura organizacional.

En esta evolución, no es suficiente la adopción de prácticas ágiles por los equipos de trabajo, sin un desarrollo específico para incrementar el nivel de consciencia de quienes lideran la organización.

Este desarrollo sistémico del liderazgo ágil es clave para lograr una agilidad organizacional efectiva y sostenible.

### ¿Cómo lo hacemos …?

Para lograr un impacto en el liderazgo de las personas que participan del programa, combinamos distintos enfoques pedagógicos, tanto a nivel individual como a nivel grupal.

- **Desarrollo Individual**: evaluación del liderazgo propio, coaching ejecutivo individual, con seteo de objetivos de mejoras y experimentos a realizar y un seguimiento individual.

- **Desarrollo Grupal**: sesiones de entrenamiento, ejercicios de acercamiento y puesta en práctica, clínicas de casos reales y resolución de dudas.
'''

@event_type.takeaways = 
'''
Este programa es más que un curso de liderazgo ágil.

El Programa de Desarrollo del Liderazgo Ágil (DLA), se enfoca en expandir el nivel de conciencia de quienes lideran la organización, para ampliar su impacto en sus equipos y sus resultados de negocio.

DLA está diseñado para construir unas bases sólidas para la evolución organizacional hacia una agilidad efectiva y sostenible.

- **Radar de Liderazgo Ágil**:  autoevaluación y evaluación por sus colaboradores.
- **Sesiones individuales** que incluyen:
  - **Debrief**, para interpretar los resultados del Radar de Liderazgo Ágil e identificar los desafíos de liderazgo a trabajar.
  - **Coaching Ejecutivo**, para acompañar a la persona en la evolución de su liderazgo, y guiarla en su experimentación de mejoras.
  - **Cierre**, para hacer un balance del desarrollo individual y delinear los próximos pasos.
- **Encuentros grupales** online en vivo semanales:
  - **Encuentro de Lanzamiento** del Programa
  - Talleres de **Entrenamiento**
  - Encuentros de **Checkpoints** con Clínicas de Casos y Actividades Grupales de Repaso
  - Encuentro de Cierre del Programa
- **Plataforma online** del programa, con materiales de trabajo, videos, referencias adicionales para profundizar, actividades individuales o grupales de puesta en práctica.
'''

@event_type.recipients = 
'''
El programa está destinado tanto a personas con experiencia en liderazgo y agilidad, como a quienes recién empiezan.

- Dirección y C-Level
- Gerentes y coordinadores de área
- Agentes de cambio en la organización
- Líderes de equipos
- Líderes técnicos
- Personas con liderazgo en distintas áreas: recursos humanos
'''

@event_type.program = 
'''
#### Modelos para el Liderazgo Ágil
Reinventando las Organizaciones (Laloux, Wilber, Beck & Cowan), 
Corazón de la Agilidad (Cockburn), Liderando en la Complejidad con 
Cynefin (Snowden), Liderazgo Tribal (Logan), Pensamiento Sistémico (Meadows).

#### Empoderar los Equipos
Toma de Decisión Colaborativa (Kaner), Delegación Progresiva (Apello), 
Facilitación de Conversaciones Grupales, Preguntas Poderosas (Bandler & Grinder).

#### Desarrollar los Equipos
Motivación Intrínseca y Extrínseca (Pink), Formación de Equipo (Tuckman), Evolución de la Confianza (Case), Feedback Efectivo (Apello, Rosenberg, Cessan).

#### Cuidar e Integrar
Priorización y Decir No, Comunicación No Violenta (Rosenberg), Escucha Empática (Rosenberg, Schamer), Actos Sutiles de Exclusión (Jana & Baran). 

#### Conducir el Cambio
Etapas del Cambio con ADKAR (Prosci), Cambio Sistémico con Doble Bucle (Berkana), Modelado Sistémico (Meadows), Experimentación y Errores, Diversidad, Equidad e Inclusión.

#### Y además ...
El contenido es tentativo se adapta en función del contexto, de las necesidades de la organización y participantes, y de la cantidad de sesiones grupales
'''

@event_type.cta = 
'''
<img src="https://kleer-images.s3.sa-east-1.amazonaws.com/DLA+CTA.png"/>
'''

  erb :'services/landing/index', layout: :'layout/layout2022'
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
