require 'sinatra'
require 'sinatra/r18n'
require 'sinatra/flash'
require 'redcarpet'
require 'json'
require 'i18n'
require 'money'
require 'escape_utils'

require './lib/metatags'
require './lib/keventer_reader'
require './lib/twitter_card'
require './lib/twitter_reader'

require './lib/books'
require './lib/resources'

require './controllers/helper'
require './controllers/blog_controller'
require './controllers/press_controller'
require './controllers/training_controller'

include MetaTags

if production?
  require 'rack/ssl-enforcer'
  use Rack::SslEnforcer
end
use Rack::Deflater

helpers do
  include Helpers
end

configure do
  set :static_cache_control, [:public, { max_age: 60 * 60 * 24 * 3 }] # 3 days

  set :views, "#{File.dirname(__FILE__)}/views"

  I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'locales', '*.yml').to_s]

  enable :sessions
  KeventerReader.build
end

before do
  session[:locale] = if request.host.include?('kleer.us')
                       'en'
                     else
                       'es'
                     end

  if ['kleer.la', 'kleer.us', 'kleer.es', 'kleer.com.ar'].include? request.host
    redirect "https://www.#{request.host}#{request.path}"
  else
    @page_title = 'Kleer | Agile Coaching, Consulting & Training'
    flash.sweep
    @markdown_renderer = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(hard_wrap: true),
      autolink: true
    )
  end
end

before '/:locale/*' do
  locale = params[:locale]

  if %w[es en].include?(locale)
    session[:locale] = locale
    request.path_info = "/#{params[:splat][0]}"
  else
    session[:locale] = 'es'
  end
end

get '/' do
  @meta_description = 'Acompañamos hacia la agilidad organizacional.' \
                      ' Ofrecemos capacitaciones y cocreamos estrategias de adopción de formas ágiles de trabajo orientadas a objetivos.'

  @kleerers = KeventerReader.instance.kleerers session[:locale]
  erb :index, layout: false
end

get '/en' do
  redirect '/en/', 301 # permanent redirect
end

get '/es' do
  redirect '/es/', 301 # permanent redirect
end

get '/acompanamos' do
  redirect '/agilidad-organizacional', 301 # permanent redirect
end

get '/coaching' do
  redirect '/agilidad-organizacional', 301 # permanent redirect
end

get '/agilidad-organizacional' do
  @active_tab_coaching = 'active'
  @page_title = 'Te acompañamos hacia la agilidad organizacional'
  @meta_description = 'Cocreamos estrategias ágiles para lograr tus objetivos de negocio y la transformación digital. Diseño,  metodologías e innovación para equipos colaborativos.'
  @categories = KeventerReader.instance.categories session[:locale]
  erb :coaching
end

get '/e-books' do
  redirect '/publicamos', 301 # permanent redirect
end

get '/facilitacion' do
  @active_tab_facilitacion = 'active'
  @page_title += ' | Facilicación'
  erb :facilitacion
end

get '/facilitacion/grafica' do
  @active_tab_facilitacion = 'active'
  @page_title += ' | Facilicación gráfica'
  erb :facilitacion_grafica
end

get '/facilitacion/innovacion-creatividad' do
  @active_tab_facilitacion = 'active'
  @page_title += ' | Innovación y creatividad'
  erb :facilitacion_innovacion_creatividad
end

get '/facilitacion/planificacion-estrategica' do
  @active_tab_facilitacion = 'active'
  @page_title += ' | Planificación estratégica'
  erb :facilitacion_planificacion_estrategica
end

get '/facilitacion/dinamicas-eventos' do
  @active_tab_facilitacion = 'active'
  @page_title += ' | Dinámicas y eventos'
  erb :facilitacion_dinamicas_eventos
end

get '/publicamos' do
  @active_tab_publicamos = 'active'
  @page_title += ' | Publicamos'
  erb :publicamos
end

get '/libros' do
  @active_tab_publicamos = 'active'
  @page_title += ' | Libros'
  @books = Books.new.load.all

  erb :ebooks
end

get '/recursos' do
  @active_tab_publicamos = 'active'
  @page_title = 'Materiales y Recursos sobre prácticas ágiles'
  @meta_description = 'Herramientas y contenidos de Scrum, Product Owner, Scrum Master, Desarrollo de equipos, Retrospectivas, Liderazgo, Comunicación, Kanban, Agile Coaching'
  @resources = Resources.new.load.all
  erb :recursos
end

get '/recursos/primeros_pasos' do
  @active_tab_publicamos = 'active'
  @page_title += ' | Recursos'
  erb :recursos_primeros_pasos
end

get '/publicamos/scrum' do
  @active_tab_publicamos = 'active'
  @page_title += ' | Publicamos | Proyectos Ágiles con Scrum'
  erb :ebook_scrum_plain, layout: :layout_ebook_landing
end

get '/mas-productivos' do
  redirect '/publicamos/mas-productivos', 301 # permanent redirect
end

get '/publicamos/mas-productivos' do
  @active_tab_publicamos = 'active'
  @page_title += ' | Publicamos | Equipos más productivos'
  erb :ebook_masproductivos_plain, layout: :layout_ebook_landing
end

get '/posters/:poster_code' do
  poster_code = params[:poster_code].downcase

  case poster_code
  when 'scrum'
    redirect '/recursos#poster-scrum', 301 # permanent redirect
  when 'xp'
    redirect '/recursos#poster-XP', 301 # permanent redirect
  when 'manifesto'
    redirect '/recursos#poster-manifesto', 301 # permanent redirect
  else
    not_found
  end
end

get '/categoria/:category_codename' do
  @category = KeventerReader.instance.category(params[:category_codename])
  @active_tab_acompanamos = 'active'

  if @category.nil?
    status 404
  else
    @page_title += " | #{@category.name}"
    @event_types = @category.event_types.sort_by(&:name)

    erb :category
  end
end

get '/somos' do
  @active_tab_somos = 'active'
  @page_title += ' | Somos'
  @kleerers = KeventerReader.instance.kleerers session[:locale]
  erb :somos
end

get '/nuestra-filosofia' do
  @active_tab_somos = 'active'
  @page_title += ' | Nuestra filosofía'
  @kleerers = KeventerReader.instance.kleerers session[:locale]
  erb :nuestra_filosofia
end

get '/prensa' do
  @active_tab_prensa = 'active'
  @page_title += ' | Prensa'
  @kleerers = KeventerReader.instance.kleerers session[:locale]
  erb :prensa
end

get '/privacy' do
  @active_tab_privacidad = 'active'
  @page_title += ' | Declaración de privacidad'
  erb :privacy
end

get '/terms' do
  @active_tab_terminos = 'active'
  @page_title += ' | Terminos y condiciones'
  erb :terms
end

get '/clientes' do
  @page_title += ' | Nuestros clientes'
  @meta_description = 'Kleer - Coaching & Training - Estas organizaciones confían en nosotros'
  @meta_keywords = 'Kleer, Clientes, Casos, Casos de Éxito, confianza'

  erb :clientes
end

get '/last-tweet/:screen_name' do
  reader = TwitterReader.new
  return reader.last_tweet(params[:screen_name]).text
end

get '/aca-beta' do
  erb :aca_beta, layout: false
end

get '/aca-37yjeueh' do
  erb :aca_30dto, layout: false
end

get '/7-trucos-agile-coaching' do
  # erb :pac_7trucos_agile_coaching, :layout => false
  redirect 'https://agilecoachingpath.com/7-trucos', 301 # permanent redirect
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

['/preguntas-frecuentes/facturacion-pagos-internacionales',
 '/preguntas-frecuentes/facturacion-pagos-argentina',
 '/preguntas-frecuentes/facturacion-pagos-colombia'].each do |path|
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
  @page_title = '404 - No encontrado'
  erb :error_404
end

private

def create_twitter_card(event)
  card = TwitterCard.new
  card.title = event.friendly_title
  card.description = event.event_type.elevator_pitch
  card.image_url = 'https://kleer-images.s3-sa-east-1.amazonaws.com/K_social.jpg'
  card.site = '@kleer_la'
  card.creator = event.trainers[0].nil? ? '' : event.trainers[0].twitter_username
  card
end

def get_404_error_text_for_course(course_name)
  "Hemos movido la información sobre el curso '<strong>#{course_name}</strong>'. Por favor, verifica nuestro
 calendario para ver los detalles de dicho curso"
end

def course_not_found_error
  'El curso que estás buscando no fue encontrado. Es probable que ya haya ocurrido o haya sido cancelado.<br/>
Te invitamos a visitar nuestro calendario para ver los cursos vigentes y probables nuevas fechas para el curso
 que estás buscando.'
end

def valid_id?(event_id_to_test)
  !event_id_to_test.match(/^[0-9]+$/).nil?
end

def valid_country_iso_code?(country_iso_code_to_test, _event_type)
  return true if %w[otro todos].include?(country_iso_code_to_test)

  unique_countries = KeventerReader.instance.unique_countries_for_commercial_events
  unique_countries.each do |country|
    return true if country.iso_code == country_iso_code_to_test
  end

  false
end
