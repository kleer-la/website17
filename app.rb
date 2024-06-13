require 'sinatra'
require 'sinatra/r18n'
require 'sinatra/flash'
require 'json'
require 'i18n'
require 'money'
require 'escape_utils'
require 'dotenv'
require 'recaptcha'

Dotenv.load

require './lib/metatags'
require './lib/helpers/custom_markdown'
require './lib/router_helper'

require './controllers/helper'
require './controllers/resources_controller'
require './controllers/blog_controller'
require './controllers/press_controller'
require './controllers/services_controller'
require './controllers/training_controller'
require './controllers/clients_controller'
require './controllers/about_us_controller'
require './controllers/home_controller'
require './controllers/mailer_controller'
require './controllers/news_controller'
require './controllers/certificates_controller'

include MetaTags
include Recaptcha::Adapters::ViewMethods

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
  set :recaptcha_public_key, ENV['RECAPTCHA_PUBLIC_KEY']
  set :recaptcha_private_key, ENV['RECAPTCHA_PRIVATE_KEY']
  set :views, "#{File.dirname(__FILE__)}/views"
  set :logging, Logger::DEBUG

  I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'locales', '*.yml').to_s]

  enable :sessions
  register Sinatra::Flash
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
    # flash.sweep
    @markdown_renderer = CustomMarkdown.new
  end


  router_helper = RouterHelper.instance
  router_helper.lang = session[:locale]
  router_helper.set_current_route(request.path)
  router_helper.alternate_route = nil
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

get '/agilidad-organizacional' do
  return redirect('/es/servicios', 301)   if session[:locale] == 'es'

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
  'e-books' => 'es/recursos',
  'libros' => 'es/recursos',
  'publicamos' => 'es/recursos',
  'posters/scrum' => 'es/recursos#poster-scrum',
  'posters/XP' => 'es/recursos#poster-XP',
  'posters/xp' => 'es/recursos#poster-XP',
  'posters/manifesto' => 'es/recursos#poster-manifesto',
  'facilitacion' => 'es/servicios/facilitacion',
  'facilitacion/grafica' => 'es/servicios/facilitacion',
  'facilitacion/innovacion-creatividad' => 'es/servicios/facilitacion',
  'facilitacion/planificacion-estrategica' => 'es/servicios/facilitacion',
  'facilitacion/dinamicas-eventos' => 'es/servicios/facilitacion',
  'preguntas-frecuentes/certified-scrum-master' => 'es/cursos/7-certified-scrum-master-csm', #  #faq / qna
  'preguntas-frecuentes/certified-scrum-developer' => 'es/cursos/342-certified-scrum-developer-csd', #  #faq / qna
  'acompanamos' => 'es/servicios',
  'coaching' => 'es/servicios'
}.freeze

PERMANENT_REDIRECT.each do |uris|
  get '/'+uris[0] do
     redirect '/'+uris[1], 301
  end
  get '/'+uris[0]+'/' do
    redirect '/'+uris[1], 301
  end
end

# LEGACY ====================

private

def get_404_error_text_for_course(course_name)
  "Hemos movido la información sobre el curso '<strong>#{course_name}</strong>'. Por favor, verifica nuestro
 calendario para ver los detalles de dicho curso"
end

def valid_id?(event_id_to_test)
  !event_id_to_test.match(/^[0-9]+$/).nil?
end
