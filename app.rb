require 'sinatra'
require 'sinatra/r18n'
require 'sinatra/flash'
require 'redcarpet'
require 'json'
require 'i18n'
require 'money'
require 'rss'
require 'escape_utils'
require 'rack/reverse_proxy'

require './lib/keventer_reader'
require './lib/dt_helper'
require './lib/twitter_card'
require './lib/twitter_reader'
require './lib/pdf_catalog'
require './lib/crm_connector'
require './lib/toggle'

require './lib/event_type'
require './lib/books'
require './lib/resources'

if production?
    require 'rack/ssl-enforcer'
    use Rack::SslEnforcer
end

helpers do

  MONTHS_ES = { "Jan" => "Ene", "Feb" => "Feb", "Mar" => "Mar", "Apr" => "Abr", "May" => "May", "Jun" => "Jun",
                "Jul" => "Jul", "Aug" => "Ago", "Sep" => "Sep", "Oct" => "Oct", "Nov" => "Nov", "Dec" => "Dic"}

  def month_es(month_en)
    MONTHS_ES[month_en]
  end

  def feature_on?(feature)
    Toggle.on?(feature)
  end

  def t(key, ops = Hash.new)
    ops.merge!(:locale => session[:locale])
    I18n.t key, ops
  end

  def url_sanitize(data)
    sanitized = data;
    sanitized = sanitized.gsub('á', 'a')
    sanitized = sanitized.gsub('é', 'e')
    sanitized = sanitized.gsub('í', 'i')
    sanitized = sanitized.gsub('ó', 'o')
    sanitized = sanitized.gsub('ú', 'u')
    sanitized = sanitized.gsub('Á', 'A')
    sanitized = sanitized.gsub('E', 'E')
    sanitized = sanitized.gsub('Í', 'I')
    sanitized = sanitized.gsub('Ó', 'O')
    sanitized = sanitized.gsub('Ú', 'U')
  end

  def currency_symbol_for( iso_code )
    currency = Money::Currency.table[iso_code.downcase.to_sym] unless iso_code.nil?
    if currency.nil?
      ""
    else
      currency[:symbol]
    end
  end

  def money_format( amount )
      parts = amount.round(0).to_s.split('.')
      parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1.")
      parts.join "."
  end
end

configure do
  set :views, "#{File.dirname(__FILE__)}/views"

  I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'locales', '*.yml').to_s]

  enable :sessions
  KeventerReader.build

  use Rack::ReverseProxy do
    reverse_proxy_options timeout: 30
    reverse_proxy_options preserve_host: true
    # reverse_proxy_options username: 'basic-auth-username', password: 'basic-auth-password'
    reverse_proxy /^\/blog-nuevo(\/.*)$/, 'https://kleer.evolucionagil.com/blog$1'
  end
end

before do

  if request.host.include?( "kleer.us" )
    session[:locale] = 'en'
  else
    session[:locale] = 'es'
  end

  if request.host == "kleer.la" || request.host == "kleer.us" || request.host == "kleer.es" || request.host == "kleer.com.ar"
    redirect "https://www." + request.host + request.path
  else
    @page_title = "Kleer - Agile Coaching & Training"
    flash.sweep
    @markdown_renderer = Redcarpet::Markdown.new(
                              Redcarpet::Render::HTML.new(:hard_wrap => true),
                              :autolink => true)
  end
end

before '/:locale/*' do
  locale = params[:locale]

  if locale == "es" || locale == "en"
    session[:locale] = locale
    request.path_info = '/' + params[:splat ][0]
  else
    session[:locale] = 'es'
  end
end

get '/' do
  @kleerers = KeventerReader.instance.kleerers session[:locale]
	erb :index, :layout => false
end

get '/en' do
  redirect "/en/", 301 # permanent redirect
end

get '/es' do
  redirect "/es/", 301 # permanent redirect
end

get '/blog' do
  @active_tab_blog = "active"
  @rss = RSS::Parser.parse('https://medium.com/feed/kleer', false)
  erb :blog, :layout => :layout_2017
end

get '/blog-nuevo' do
  redirect "/blog-nuevo/", 301 # permanent redirect
end

get '/entrenamos/:country?' do |country|
	entrenamos_view(country)
end
get '/entrenamos' do
	entrenamos_view
end

def entrenamos_view(country=nil)
	if !country.nil? && country!='todos' && country.length>2
	    status 404
	else
		@active_tab_entrenamos = "active"
		@page_title += " | Entrenamos"
		@unique_countries = KeventerReader.instance.unique_countries_for_commercial_events()
		@country= country || session[:filter_country] || 'todos'
    session[:filter_country]= @country
    erb :entrenamos, :layout => :layout_2017
	end
end


get '/acompanamos' do
  redirect "/agilidad-organizacional", 301 # permanent redirect
end

get '/coaching' do
  redirect "/agilidad-organizacional", 301 # permanent redirect
end

get '/agilidad-organizacional' do
	@active_tab_coaching = "active"
	@page_title += " | Coaching"
	@categories = KeventerReader.instance.categories session[:locale]
	erb :coaching, :layout => :layout_2017
end

get '/e-books' do
  redirect "/publicamos", 301 # permanent redirect
end

get '/facilitacion' do
  @active_tab_facilitacion = "active"
  @page_title += " | Facilicación"
  erb :facilitacion, :layout => :layout_2017
end

get '/facilitacion/grafica' do
  @active_tab_facilitacion = "active"
  @page_title += " | Facilicación gráfica"
  erb :facilitacion_grafica, :layout => :layout_2017
end

get '/facilitacion/innovacion-creatividad' do
  @active_tab_facilitacion = "active"
  @page_title += " | Innovación y creatividad"
  erb :facilitacion_innovacion_creatividad, :layout => :layout_2017
end

get '/facilitacion/planificacion-estrategica' do
  @active_tab_facilitacion = "active"
  @page_title += " | Planificación estratégica"
  erb :facilitacion_planificacion_estrategica, :layout => :layout_2017
end

get '/facilitacion/dinamicas-eventos' do
  @active_tab_facilitacion = "active"
  @page_title += " | Dinámicas y eventos"
  erb :facilitacion_dinamicas_eventos, :layout => :layout_2017
end

get '/publicamos' do
  @active_tab_publicamos = "active"
  @page_title += " | Publicamos"
  erb :publicamos, :layout => :layout_2017
end


get '/libros' do
  @active_tab_publicamos = "active"
  @page_title += " | Libros"
  @books= (Books.new).load.all

  erb :ebooks, :layout => :layout_2017
end

get '/recursos' do
  @active_tab_publicamos = "active"
  @page_title += " | Recursos"
  @resources= (Resources.new).load.all
  erb :recursos, :layout => :layout_2017
end

get '/recursos/primeros_pasos' do
  @active_tab_publicamos = "active"
  @page_title += " | Recursos"
  erb :recursos_primeros_pasos, :layout => :layout_2017
end

get '/publicamos/scrum' do
  @active_tab_publicamos = "active"
  @page_title += " | Publicamos | Proyectos Ágiles con Scrum"
  erb :ebook_scrum_plain, :layout => :layout_ebook_landing
end

get '/mas-productivos' do
  redirect "/publicamos/mas-productivos", 301 # permanent redirect
end

get '/publicamos/mas-productivos' do
  @active_tab_publicamos = "active"
  @page_title += " | Publicamos | Equipos más productivos"
  erb :ebook_masproductivos_plain, :layout => :layout_ebook_landing
end

get '/posters/:poster_code' do
  poster_code = params[:poster_code].downcase

  case poster_code
  when "scrum" 
    redirect "/recursos#poster-scrum", 301 # permanent redirect
  when "xp"
    redirect "/recursos#poster-XP", 301 # permanent redirect
  when "manifesto"
    redirect "/recursos#poster-manifesto", 301 # permanent redirect
  else
    not_found
  end
end

get '/categoria/:category_codename' do
  @category = KeventerReader.instance.category(params[:category_codename])
  @active_tab_acompanamos = "active"

  if @category.nil?
    status 404
  else
    @page_title += " | " + @category.name
    @event_types = @category.event_types.sort_by { |et| et.name}

    erb :category, :layout => :layout_2017
  end
end

# Nuevo dispatcher de evento/id -> busca el tipo de evento y va a esa View
get '/entrenamos/evento/:event_id_with_name' do
  event_id_with_name = params[:event_id_with_name]
  event_id = event_id_with_name.split('-')[0]
  if is_valid_id(event_id)
    @event = KeventerReader.instance.event(event_id, true)
  end

  if @event.nil?
    flash.now[:error] = get_course_not_found_error()
    redirect to('/entrenamos')
  else
    uri = "/cursos/#{ @event.event_type.id }-#{@event.event_type.name }"

    redirect uri #, 301 # permanent redirect = REACTIVAR CUANDO ESTE TODO LISTO!
  end
end

get '/catalogo' do
  @active_tab_entrenamos = "active"
  #pdf_catalog
  @page_title += " | Catálogo"
  @categories = KeventerReader.instance.categories session[:locale]
  erb :catalogo, :layout => :layout_2017
end

# Nueva (y simplificada) ruta para Tipos de Evento
get '/cursos/:event_type_id_with_name' do
  @active_tab_entrenamos = "active"

  event_type_id_with_name = params[:event_type_id_with_name]
  event_type_id = event_type_id_with_name.split('-')[0]

  if is_valid_id(event_type_id)
    @event_type = KeventerReader.instance.event_type(event_type_id, true)
  end

  if !params[:utm_source].nil? && !params[:utm_campaign].nil? && params[:utm_source] != "" && params[:utm_campaign] != ""
    @tracking_parameters = "&utm_source=#{params[:utm_source]}&utm_campaign=#{params[:utm_campaign]}"
  else
    @tracking_parameters = "&utm_source=kleer.la&utm_campaign=kleer.la"
  end

  if @event_type.nil?
    flash.now[:error] = get_course_not_found_error()
    erb :error404_to_calendar, :layout => :layout_2017
  else
    @page_title = "Kleer - " + @event_type.name

    if @event_type.categories.count > 0
      # Podría tener más de una categoría, pero se toma el codename de la primera como la del catálogo
      @category = KeventerReader.instance.category @event_type.categories[0][1], session[:locale]
    end
    erb :event_type, :layout => :layout_2017
  end
end

# Ruta antigua para Tipos de Evento (redirige a la nueva)
get '/categoria/:category_codename/cursos/:event_type_id_with_name' do
  redirect to "/cursos/#{params[:event_type_id_with_name]}"
end

get '/entrenamos/evento/:event_id_with_name/entrenador/remote' do
  event_id_with_name = params[:event_id_with_name]

  event_id = event_id_with_name.split('-')[0]
  if is_valid_id(event_id)
    @event = KeventerReader.instance.event(event_id, false)
  end

  if @event.nil?
    @error = get_course_not_found_error()
    erb :error404_remote_to_calendar, :layout => :layout_empty
  else
    erb :trainer_remote, :layout => :layout_empty
  end
end

get '/entrenamos/evento/:event_id_with_name/remote' do
  event_id_with_name = params[:event_id_with_name]

  event_id = event_id_with_name.split('-')[0]
  if is_valid_id(event_id)
    @event = KeventerReader.instance.event(event_id, false)
  end

  if @event.nil?
    @error = get_course_not_found_error()
    erb :error404_remote_to_calendar, :layout => :layout_empty
  else
    erb :event_remote, :layout => :layout_empty
  end
end

get '/entrenamos/evento/:event_id_with_name/registration' do
  event_id_with_name = params[:event_id_with_name]

  event_id = event_id_with_name.split('-')[0]
  if is_valid_id(event_id)
    @event = KeventerReader.instance.event(event_id, false)
  end

  if @event.nil?
    @error = get_course_not_found_error()
    erb :error404_remote_to_calendar, :layout => :layout_empty
  else
    erb :event_remote_registration, :layout => :layout_empty
  end
end

get '/somos' do
 	@active_tab_somos = "active"
	@page_title += " | Somos"
	@kleerers = KeventerReader.instance.kleerers session[:locale]
	erb :somos, :layout => :layout_2017
end

get '/nuestra-filosofia' do
  @active_tab_somos = "active"
  @page_title += " | Nuestra filosofía"
  @kleerers = KeventerReader.instance.kleerers session[:locale]
  erb :nuestra_filosofia, :layout => :layout_2017
end

get '/prensa' do
  @active_tab_prensa = "active"
  @page_title += " | Prensa"
  @kleerers = KeventerReader.instance.kleerers session[:locale]
  erb :prensa, :layout => :layout_2017
end

get '/privacy' do
  @active_tab_privacidad = "active"
  @page_title += " | Declaración de privacidad"
  erb :privacy, :layout => :layout_2017
end

get '/terms' do
  @active_tab_terminos = "active"
  @page_title += " | Terminos y condiciones"
  erb :terms, :layout => :layout_2017
end

get '/clientes/equipos-scrum-en-technisys-2015' do
  redirect '/prensa/casos/equipos-scrum-en-technisys-2015', 301 # permanent redirect
end

get '/prensa/casos/equipos-scrum-en-technisys-2015' do
  @page_title += " | Equipos de desarrollo Scrum y Automatización en Technisys"
  @meta_description = "Kleer - Coaching & Training - Equipos de desarrollo Scrum y automatización de despliegue de software en Technisys apoyados por Kleer"
  @meta_keywords = "Kleer, Technisys, CyberBank, scrum, equipos, desarrollo ágil, devops, automatización, integración continua, jenkins"

  erb :prensa_casos_technisys_2015, :layout => :layout_2017
end

get '/clientes/equipos-scrum-en-plataforma-10-2015' do
  redirect '/prensa/casos/equipos-scrum-en-plataforma-10-2015', 301 # permanent redirect
end

get '/prensa/casos/equipos-scrum-en-plataforma-10-2015' do
  @page_title += " | Equipos de desarrollo Scrum y Automatización en Plataforma 10"
  @meta_description = "Kleer - Coaching & Training - Equipos de desarrollo Scrum y orientación al valor para el negocio en Plataforma 10, apoyados por Kleer"
  @meta_keywords = "Kleer, Plataforma 10, scrum, equipos, desarrollo ágil, devops, automatización, integración continua, valor negocio"

  erb :prensa_casos_plataforma_10_2015, :layout => :layout_2017
end

get '/clientes/equipos-scrum-en-suramericana-2015' do
  redirect '/prensa/casos/equipos-scrum-en-suramericana-2015', 301 # permanent redirect
end

get '/prensa/casos/equipos-scrum-en-suramericana-2015' do
  @page_title += " | Paradigma ágil en tecnología y en negocio en Suramericana"
  @meta_description = "Kleer - Coaching & Training - Paradigma ágiles en tecnología y en negocio en Suramericana, apoyados por Kleer"
  @meta_keywords = "Kleer, Suramericana, Sura, scrum, equipos, desarrollo ágil, valor negocio, corporaciones ágiles, paradigma ágil en las empresas"

  erb :prensa_casos_suramericana_2015, :layout => :layout_2017
end

get '/clientes/innovacion-en-marketing-digital-loreal-2016' do
  redirect '/prensa/casos/innovacion-en-marketing-digital-loreal-2016', 301 # permanent redirect
end

get '/prensa/casos/transformacion-agil-ypf-2020' do
  @page_title += " | Así profundizó YPF su camino de transformación ágil"
  @meta_description = "Kleer - Coaching & Training - Creación incremental y colaborativa de estrategias digitales facilitada por Kleer"
  @meta_keywords = "Kleer, L'Oréal, Loreal, Innovación, Design Thinking, facilitación, coloaboración, facilitación gráfica, marketing, digital"

  erb :prensa_casos_ypf_2020, :layout => :layout_2017
end

get '/prensa/casos/innovacion-en-marketing-digital-loreal-2016' do
  @page_title += " | Innovación en Marketing Digital en L'Oréal"
  @meta_description = "Kleer - Coaching & Training - Creación incremental y colaborativa de estrategias digitales facilitada por Kleer"
  @meta_keywords = "Kleer, L'Oréal, Loreal, Innovación, Design Thinking, facilitación, coloaboración, facilitación gráfica, marketing, digital"

  erb :prensa_casos_loreal_2016, :layout => :layout_2017
end

get '/prensa/casos/transformacion-cultural-agil-ti-epm-2018' do
  @page_title += " | EPM se transforma culturalmente"
  @meta_description = "Kleer - Coaching & Training - Cómo acompañamos desde Kleer la transformación ágil de TI en EPM"
  @meta_keywords = "Kleer, epm, empresas publicas medellin, scrum, equipos, coaching, cambio cultural, agilidad, agile, caso de exito, sistemas, ti, mejora continua, transformación organizacional, evolución organizacional"

  erb :prensa_casos_epm_2018, :layout => :layout_2017
end

get '/prensa/casos/transformacion-digital-bbva-continental' do
  @page_title += " | Acompañamiento en la transformación digital de BBVA Continental"
  @meta_description = "Kleer - Coaching & Training -Acompañamiento en la transformación digital de BBVA Continental"
  @meta_keywords = "Kleer, scrum, equipos, coaching, cambio cultural, agilidad, agile, caso de exito, mejora continua, transformación organizacional, evolución organizacional"

  erb :prensa_casos_bbva_2018, :layout => :layout_2017
end

get '/prensa/casos/falabella-financiero' do
  @page_title += " | Transformación Organizacional en Falabella Financiero"
  @meta_description = "Kleer - Coaching & Training - Transformación Organizacional en Falabella Financiero"
  @meta_keywords = "Kleer, scrum, equipos, coaching, cambio cultural, agilidad, agile, caso de exito, mejora continua, transformación organizacional, evolución organizacional"

  erb :prensa_casos_falabella_financiero, :layout => :layout_2017
end

get '/prensa/casos/afp-crecer' do
  @page_title += " | Coaching y transformación ágil en AFP Crecer"
  @meta_description = "Kleer - Coaching & Training - Coaching y transformación ágil en AFP Crecer"
  @meta_keywords = "Kleer, scrum, equipos, coaching, cambio cultural, agilidad, agile, caso de exito, mejora continua, transformación organizacional, evolución organizacional"

  erb :prensa_casos_afp_crecer, :layout => :layout_2017
end

get '/prensa/casos/capacitaciones-agiles-endava' do
  @page_title += " | Jornada de capacitaciones ágiles en Endava"
  @meta_description = "Kleer - Coaching & Training - Endava, una empresa internacional que ofrece servicios de desarrollo de software con presencia en Latinoamérica, Estados Unidos y Europa, se vio en el desafío de mantener la cultura ágil dentro de un contexto de gran crecimiento en poco tiempo."
  @meta_keywords = "Kleer, Agile training, Scrum, Kanban, Trabajo en equipo, Capacitación"

  erb :prensa_casos_endava_2018, :layout => :layout_2017
end

get '/clientes' do
  @page_title += " | Nuestros clientes"
  @meta_description = "Kleer - Coaching & Training - Estas organizaciones confían en nosotros"
  @meta_keywords = "Kleer, Clientes, Casos, Casos de Éxito, confianza"

  erb :clientes, :layout => :layout_2017
end

get '/last-tweet/:screen_name' do
  reader = TwitterReader.new
  return reader.last_tweet(params[:screen_name]).text
end

get '/aca-beta' do
  erb :aca_beta, :layout => false
end

get '/aca-37yjeueh' do
  erb :aca_30dto, :layout => false
end

get '/7-trucos-agile-coaching' do
  #erb :pac_7trucos_agile_coaching, :layout => false
  redirect "https://agilecoachingpath.com/7-trucos", 301 # permanent redirect
end

# JSON ====================

get '/entrenamos/eventos/proximos' do
  content_type :json
  DTHelper::to_dt_event_array_json(KeventerReader.instance.coming_commercial_events(), true, "cursos")
end

get '/entrenamos/eventos/proximos/:amount' do
  content_type :json
  amount = params[:amount]
  if !amount.nil?
    amount = amount.to_i
  end
  DTHelper::to_dt_event_array_json(KeventerReader.instance.coming_commercial_events(), true, "cursos", I18n, session[:locale], amount, false)
end

get '/entrenamos/eventos/pais/:country_iso_code' do
  content_type :json
  country_iso_code = params[:country_iso_code]
  if (!is_valid_country_iso_code(country_iso_code, "cursos"))
    country_iso_code = "todos"
  end
  session[:filter_country]= country_iso_code
  DTHelper::to_dt_event_array_json(KeventerReader.instance.commercial_events_by_country(country_iso_code), false, "cursos", I18n, session[:locale])
end

[ '/preguntas-frecuentes/facturacion-pagos-internacionales',
  '/preguntas-frecuentes/facturacion-pagos-argentina',
  '/preguntas-frecuentes/facturacion-pagos-colombia'
].each do |path| 
  get path do
    redirect '/', 301 # permanent redirect
  end
end 

get '/preguntas-frecuentes/certified-scrum-master' do
  redirect '/categoria/clientes/cursos/7-certified-scrum-master-(csm)', 301 # permanent redirect
end

get '/preguntas-frecuentes/certified-scrum-developer' do
  redirect '/categoria/clientes/cursos/342-certified-scrum-developer-(csd)', 301 # permanent redirect
end

# LEGACY ====================

not_found do
  @page_title = "404 - No encontrado"
  erb :error404, :layout => :layout_2017
end

private

def create_twitter_card( event )
  card = TwitterCard.new
  card.title = event.friendly_title
  card.description = event.event_type.elevator_pitch
  card.image_url = "https://kleer-images.s3-sa-east-1.amazonaws.com/K_social.jpg"
  card.site = "@kleer_la"
  if event.trainers[0].nil?
    card.creator = ""
  else
    card.creator = event.trainers[0].twitter_username
  end
  card
end

def get_404_error_text_for_course(course_name)
  "Hemos movido la información sobre el curso '<strong>#{course_name}</strong>'. Por favor, verifica nuestro calendario para ver los detalles de dicho curso"
end

def get_course_not_found_error
  "El curso que estás buscando no fue encontrado. Es probable que ya haya ocurrido o haya sido cancelado.<br/>Te invitamos a visitar nuestro calendario para ver los cursos vigentes y probables nuevas fechas para el curso que estás buscando."
end

def is_valid_id(event_id_to_test)
  !(event_id_to_test.match(/^[0-9]+$/).nil?)
end

def is_valid_country_iso_code(country_iso_code_to_test, event_type)
  return true if (country_iso_code_to_test == "otro" or country_iso_code_to_test == "todos")

  unique_countries = KeventerReader.instance.unique_countries_for_commercial_events()
  unique_countries.each { |country|
    if (country.iso_code == country_iso_code_to_test)
      return true
    end
  }

  return false
end
