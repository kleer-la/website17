require 'sinatra'
require 'sinatra/r18n'
require 'sinatra/flash'
require 'json'
require 'i18n'
require 'money'
require 'escape_utils'
require 'recaptcha'

require './lib/metatags'
require './lib/helpers/custom_markdown'
require './lib/helpers/timestamp'

# Load all helper files from lib/helpers
Dir[File.join(File.dirname(__FILE__), 'lib', 'helpers', '*.rb')].each { |file| require file }

# Register all modules that end with "Helper"
ObjectSpace.each_object(Module) do |m|
  helpers m if m.is_a?(Module) && !m.is_a?(Class) && m.name && m.name.end_with?('Helper')
end

require './lib/models/shorter_url'

require './controllers/helper'
require './controllers/assessments_controller'
require './controllers/resources_controller'
require './controllers/blog_controller'
require './controllers/services_controller'
require './controllers/training_controller'
require './controllers/clients_controller'
require './controllers/about_us_controller'
require './controllers/home_controller'
require './controllers/mailer_controller'
require './controllers/news_controller'
require './controllers/certificates_controller'
require './controllers/podcasts_controller'
require './controllers/event_controller'

include MetaTags
include Recaptcha::Adapters::ViewMethods

if production?
  require 'rack/ssl-enforcer'
  use Rack::SslEnforcer
end
use Rack::Deflater

helpers do
  include Helpers
  include TimestampHelpers
end

configure do
  set :static_cache_control, [:public, { max_age: 60 * 60 * 24 * 3 }] # 3 days
  set :recaptcha_public_key, ENV['RECAPTCHA_PUBLIC_KEY']
  set :recaptcha_private_key, ENV['RECAPTCHA_PRIVATE_KEY']
  set :views, "#{File.dirname(__FILE__)}/views"
  set :logging, Logger::INFO

  I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'locales', '*.yml').to_s]

  enable :sessions
  register Sinatra::Flash
end

configure :test, :development do
  set :protection, except: [:host_authorization]
end

before do
  # Handle subdomain routing
  @is_latelier = request.host.start_with?('latelier.')
  
  target_url, locale = unify_domains(request.host, request.path)
  session[:locale] = locale if locale # Set only if locale is non-nil
  if target_url
    redirect target_url, 301
  else
    @base_title = @is_latelier ? 'L\'Atelier - Kleer' : 'Agile Coaching, Consulting & Training'
    @meta_tags = Tags.new
    @meta_tags.set! title: @base_title, path: request.path
    # flash.sweep
    @markdown_renderer = CustomMarkdown.new
  end

  headers['X-Robots-Tag'] = 'noindex, nofollow' if request.host.include? 'qa2'

  router_helper = RouterHelper.instance
  router_helper.lang = session[:locale]
  router_helper.set_current_route(request.path)
  router_helper.alternate_route = nil
end

before '/s/:short_code' do
  pass  # Bypass locale handling for /s/ routes
end

before '/:locale/*' do
  locale = params[:locale]

  if %w[es en].include?(locale)
    session[:locale] = locale
    path = "/#{params[:splat][0]}"

    # Check for mixed language URLs and redirect if needed
    corrected_path = RouterHelper.detect_mixed_language(locale, path)
    if corrected_path
      redirect "/#{locale}#{corrected_path}", 301
    end

    request.path_info = path
  else
    session[:locale] = 'es'
  end
  I18n.locale = session[:locale]
end
get '/robots.txt' do
  content_type :text
  <<-ROBOTS
  User-agent: *
  Disallow: /.well-known/apple-app-site-association
  Disallow: /apple-app-site-association
  ROBOTS
end
get '/en' do
  redirect '/en/', 301 # permanent redirect
end

get '/es' do
  redirect '/es/', 301 # permanent redirect
end

# TODO: redirect
PERMANENT_REDIRECT = {
  'e-books' => 'es/recursos',
  'libros' => 'es/recursos',
  'publicamos' => 'es/recursos',
  'publicamos/scrum' => 'es/recursos/proyectos-agiles-scrum',
  'publicamos/mas-productivos' => 'es/recursos',
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
  'coaching' => 'es/servicios',
  'agilidad-organizacional/mejora-continua' => 'es/servicios/kaizen-team',

  'prensa/casos/afp-crecer' => 'es/blog/afp-crecer',
  'clientes/afp-crecer' => 'es/blog/afp-crecer',
  'prensa/casos/transformacion-digital-bbva-continental' => 'es/blog/transformacion-digital-bbva-continental',
  'clientes/transformacion-digital-bbva-continental' => 'es/blog/transformacion-digital-bbva-continental',
  'prensa/casos/capacitaciones-agiles-endava' => 'es/blog/capacitaciones-agiles-endava',
  'clientes/capacitaciones-agiles-endava' => 'es/blog/capacitaciones-agiles-endava',
  'prensa/casos/transformacion-cultural-agil-ti-epm-2018' => 'es/blog/transformacion-cultural-agil-ti-epm-2018',
  'clientes/transformacion-cultural-agil-ti-epm-2018' => 'es/blog/transformacion-cultural-agil-ti-epm-2018',
  'prensa/casos/falabella-financiero' => 'es/blog/falabella-financiero',
  'clientes/falabella-financiero' => 'es/blog/falabella-financiero',
  'prensa/casos/innovacion-en-marketing-digital-loreal-2016' => 'es/blog/innovacion-en-marketing-digital-loreal-2016',
  'clientes/innovacion-en-marketing-digital-loreal-2016' => 'es/blog/innovacion-en-marketing-digital-loreal-2016',
  'prensa/casos/equipos-scrum-en-suramericana-2015' => 'es/blog/equipos-scrum-en-suramericana-2015',
  'clientes/equipos-scrum-en-suramericana-2015' => 'es/blog/equipos-scrum-en-suramericana-2015',
  'prensa/casos/equipos-scrum-en-plataforma-10-2015' => 'es/blog/equipos-scrum-en-plataforma-10-2015',
  'clientes/equipos-scrum-en-plataforma-10-2015' => 'es/blog/equipos-scrum-en-plataforma-10-2015',
  'prensa/casos/equipos-scrum-en-technisys-2015' => 'es/blog/equipos-scrum-en-technisys-2015',
  'clientes/equipos-scrum-en-technisys-2015' => 'es/blog/equipos-scrum-en-technisys-2015',
  'prensa/casos/transformacion-agil-ypf-2020' => 'es/blog/transformacion-agil-ypf-2020',
  'clientes/transformacion-agil-ypf-2020' => 'es/blog/transformacion-agil-ypf-2020'
}.freeze

PERMANENT_REDIRECT.each do |original, redirect|
  get "/#{original}" do
    redirect "/#{redirect}", 301
  end
  get "/#{original}/" do
    redirect "/#{redirect}", 301
  end
end

get '/s/:short_code' do |short_code|
  dest = ShorterUrl.create_keventer(short_code)

  unless dest.nil?
    redirect dest.original_url, 301
  else
    halt 404
  end
end

get '/cache-reset' do
  token = params[:token]
  expected_token = ENV['CACHE_RESET_TOKEN']

  if expected_token.nil? || expected_token.empty?
    halt 503, 'Cache reset not configured'
  end

  if token.nil? || token != expected_token
    halt 403, 'Invalid token'
  end

  CacheService.clear
  stats = CacheService.stats

  content_type :json
  { status: 'ok', message: 'Cache cleared successfully', stats: stats }.to_json
end

private

def get_404_error_text_for_course(course_name)
  "Hemos movido la información sobre el curso '<strong>#{course_name}</strong>'. Por favor, verifica nuestro
 calendario para ver los detalles de dicho curso"
end

def valid_id?(event_id_to_test)
  !event_id_to_test.match(/^[0-9]+$/).nil?
end
