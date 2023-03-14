require 'sinatra'
require 'sinatra/r18n'
require 'sinatra/flash'
require 'redcarpet'
require 'json'
require 'i18n'
require 'money'
require 'escape_utils'
require 'dotenv'

Dotenv.load

require './lib/metatags'
require './lib/keventer_reader'
require './lib/twitter_card'
require './lib/twitter_reader'

require './lib/resources'

require './controllers/helper'
require './controllers/blog_controller'
require './controllers/press_controller'
require './controllers/services_controller'
require './controllers/training_controller'
require './controllers/clients_controller'
require './controllers/about_us_controller'
require './controllers/home_controller'
require './controllers/mailer_controller'

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

  if ['kleer.us', 'kleer.es','www.kleer.us','www.kleer.es'].include? request.host
    # redirect "https://www.#{request.host}#{request.path}"
    lang = "/#{session[:locale]}" unless %w(/en /es).include? request.path[0,3]
    redirect "https://www.kleer.la#{lang}#{request.path}"
  else
    @base_title = 'Agile Coaching, Consulting & Training'
    @meta_tags= Tags.new
    @meta_tags.set! title: @base_title, path: request.path
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

get '/en' do
  redirect '/en/', 301 # permanent redirect
end

get '/es' do
  redirect '/es/', 301 # permanent redirect
end

get '/agilidad-organizacional-old' do
  @active_tab_coaching = 'active'
  @meta_tags.set! title: 'Te acompañamos hacia la agilidad organizacional',
                  description: 'Cocreamos estrategias ágiles para lograr tus objetivos de negocio y la transformación digital. Diseño, metodologías e innovación para equipos colaborativos.'
  @categories = KeventerReader.instance.categories session[:locale]
  erb :coaching
end

get '/agilidad-organizacional' do
  @active_tab_coaching = 'active'
  @meta_tags.set! title: t('meta_tag.business-agility.title'),
                  description: t('meta_tag.business-agility.description'),
                  canonical: "#{t('meta_tag.business-agility.canonical')}"

  erb :'business_agility/index', layout: :'layout/layout2022'
end

get '/agilidad-organizacional/mejora-continua' do
  @active_tab_coaching = 'active'
  @meta_tags.set! title: 'Generamos el hábito de mejora continua - Kaizen'
  @meta_tags.set! description: 'Entrenamos, hacemos mentoría y generamos un proceso sostenible de mejora continua o kaizen'

  erb :mejora_continua
end

#TODO redirect
PERMANENT_REDIRECT = {
  'e-books' => 'es/publicamos',
  'libros' => 'es/recursos',
  'posters/scrum' => 'es/recursos#poster-scrum',
  'posters/XP' => 'es/recursos#poster-XP',
  'posters/xp' => 'es/recursos#poster-XP',
  'posters/manifesto' => 'es/recursos#poster-manifesto',
  'preguntas-frecuentes/certified-scrum-master' => 'es/cursos/7-certified-scrum-master-csm', #  #faq / qna
  'preguntas-frecuentes/certified-scrum-developer' => 'es/cursos/342-certified-scrum-developer-csd', #  #faq / qna
  'acompanamos' => 'es/agilidad-organizacional',
  'coaching' => 'es/agilidad-organizacional'
}.freeze

PERMANENT_REDIRECT.each do |uris|
  get '/'+uris[0] do
     redirect '/'+uris[1], 301
  end
end

get '/facilitacion' do
  @active_tab_facilitacion = 'active'
  @meta_tags.set! title: "#{@base_title} | Facilicación"
  erb :facilitacion
end

get '/facilitacion/grafica' do
  @active_tab_facilitacion = 'active'
  @meta_tags.set! title: "#{@base_title} | Facilicación gráfica"
  erb :facilitacion_grafica
end

get '/facilitacion/innovacion-creatividad' do
  @active_tab_facilitacion = 'active'
  @meta_tags.set! title: "#{@base_title} | Innovación y creatividad"
  erb :facilitacion_innovacion_creatividad
end

get '/facilitacion/planificacion-estrategica' do
  @active_tab_facilitacion = 'active'
  @meta_tags.set! title: "#{@base_title} | Planificación estratégica"
  erb :facilitacion_planificacion_estrategica
end

get '/facilitacion/dinamicas-eventos' do
  @active_tab_facilitacion = 'active'
  @meta_tags.set! title: "#{@base_title} | Dinámicas y eventos"
  erb :facilitacion_dinamicas_eventos
end

get '/publicamos' do
  @active_tab_publicamos = 'active'
  @meta_tags.set! title: "#{@base_title} | Publicamos"
  erb :publicamos
end

get '/recursos' do
  @active_tab_publicamos = 'active'
  @meta_tags.set!  title: t('meta_tag.resources.title'),
                   description: t('meta_tag.resources.description'),
                   canonical: "#{t('meta_tag.resources.canonical')}"

  @resources = Resources.new.load.all

  erb :'resources_page/index', layout: :'layout/layout2022'
end

get '/recursos/primeros_pasos' do
  @active_tab_publicamos = 'active'
  @meta_tags.set! title: "#{@base_title} | Recursos"
  erb :recursos_primeros_pasos
end

get '/publicamos/scrum' do
  @active_tab_publicamos = 'active'
  @meta_tags.set! title: "#{@base_title} | Publicamos | Proyectos Ágiles con Scrum"
  erb :ebook_scrum_plain, layout: :layout_ebook_landing
end

get '/mas-productivos' do
  redirect '/publicamos/mas-productivos', 301 # permanent redirect
end

get '/publicamos/mas-productivos' do
  @active_tab_publicamos = 'active'
  @meta_tags.set! title: "#{@base_title} | Publicamos | Equipos más productivos"
  erb :ebook_masproductivos_plain, layout: :layout_ebook_landing
end

get '/categoria/:category_codename' do
  @category = KeventerReader.instance.category(params[:category_codename])
  @active_tab_acompanamos = 'active'

  if @category.nil?
    status 404
  else
    @meta_tags.set! title: @category.name
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
