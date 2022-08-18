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
require './controllers/clients_controller'
require './controllers/about_us_controller'
require './controllers/home_controller'

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

  if ['kleer.us', 'kleer.es'].include? request.host
    # redirect "https://www.#{request.host}#{request.path}"
    redirect "https://www.kleer.la#{request.path}"
  else
    @base_title = 'Agile Coaching, Consulting & Training'
    meta_tags! title: @base_title
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
  I18n.locale = session[:locale]
end

get '/ebooks2022' do
  meta_tags! title: 'Libros'
  meta_tags! description: 'Descripcion libros o recursos'

  @books = Books.new.load.all

  erb :'resources_page/index_books', layout: :'layout/layout2022'
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
  meta_tags! title: 'Te acompañamos hacia la agilidad organizacional'
  meta_tags! description: 'Cocreamos estrategias ágiles para lograr tus objetivos de negocio y la transformación digital. Diseño, metodologías e innovación para equipos colaborativos.'
  @categories = KeventerReader.instance.categories session[:locale]
  erb :coaching
end

get '/agilidad-organizacional/mejora-continua' do
  @active_tab_coaching = 'active'
  meta_tags! title: 'Generamos el hábito de mejora continua - Kaizen'
  meta_tags! description: 'Entrenamos, hacemos mentoría y generamos un proceso sostenible de mejora continua o kaizen'

  erb :mejora_continua
end

get '/e-books' do
  redirect '/publicamos', 301 # permanent redirect
end

get '/facilitacion' do
  @active_tab_facilitacion = 'active'
  meta_tags! title: "#{@base_title} | Facilicación"
  erb :facilitacion
end

get '/facilitacion/grafica' do
  @active_tab_facilitacion = 'active'
  meta_tags! title: "#{@base_title} | Facilicación gráfica"
  erb :facilitacion_grafica
end

get '/facilitacion/innovacion-creatividad' do
  @active_tab_facilitacion = 'active'
  meta_tags! title: "#{@base_title} | Innovación y creatividad"
  erb :facilitacion_innovacion_creatividad
end

get '/facilitacion/planificacion-estrategica' do
  @active_tab_facilitacion = 'active'
  meta_tags! title: "#{@base_title} | Planificación estratégica"
  erb :facilitacion_planificacion_estrategica
end

get '/facilitacion/dinamicas-eventos' do
  @active_tab_facilitacion = 'active'
  meta_tags! title: "#{@base_title} | Dinámicas y eventos"
  erb :facilitacion_dinamicas_eventos
end

get '/publicamos' do
  @active_tab_publicamos = 'active'
  meta_tags! title: "#{@base_title} | Publicamos"
  erb :publicamos
end

get '/libros' do
  @active_tab_publicamos = 'active'
  meta_tags! title: "#{@base_title} | Libros"
  @books = Books.new.load.all

  erb :ebooks
end

get '/recursos' do
  @active_tab_publicamos = 'active'
  meta_tags!  title: t('meta_tag.resources.title'),
              description: t('meta_tag.resources.description')

  @resources = Resources.new.load.all

  erb :'resources_page/index', layout: :'layout/layout2022'
end

get '/recursos/primeros_pasos' do
  @active_tab_publicamos = 'active'
  meta_tags! title: "#{@base_title} | Recursos"
  erb :recursos_primeros_pasos
end

get '/publicamos/scrum' do
  @active_tab_publicamos = 'active'
  meta_tags! title: "#{@base_title} | Publicamos | Proyectos Ágiles con Scrum"
  erb :ebook_scrum_plain, layout: :layout_ebook_landing
end

get '/mas-productivos' do
  redirect '/publicamos/mas-productivos', 301 # permanent redirect
end

get '/publicamos/mas-productivos' do
  @active_tab_publicamos = 'active'
  meta_tags! title: "#{@base_title} | Publicamos | Equipos más productivos"
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
    meta_tags! title: @category.name
    @event_types = @category.event_types.sort_by(&:name)

    erb :category
  end
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

get '/retro-cono-sur' do
  erb :retro_cono_sur
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
