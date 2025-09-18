require './lib/json_api'
require './lib/services/mailer'

include Recaptcha::Adapters::ControllerMethods

def send_mail(data)
  url = data[:resource_slug] && !data[:resource_slug].empty? ? KeventerAPI.contacts_url : KeventerAPI.mailer_url
  # return JSON.parse(@response) unless @response.nil? # NullInfra -esque
  Mailer.new(url, data)
end

def send_error_notification(error_details)
  error_data = {
    name: 'Error Notification System',
    email: 'system@kleer.la',
    company: 'Kleer',
    message: format_error_message(error_details),
    context: '/participant-registration-error',
    language: 'es',
    resource_slug: '',
    initial_slug: '',
    can_we_contact: false,
    suscribe: false
  }

  begin
    send_mail(error_data)
  rescue StandardError => e
    # Log the error but don't let it crash the main error handling
    puts "Failed to send error notification email: #{e.message}"
  end
end

def format_error_message(details)
  <<~MESSAGE
    ERROR EN REGISTRO DE PARTICIPANTES

    Tipo de error: #{details[:error_type]}
    URL: #{details[:url]}
    Evento ID: #{details[:event_id]}
    Idioma: #{details[:language]}
    Timestamp: #{details[:timestamp]}

    Mensaje de error:
    #{details[:error_message]}

    Detalles adicionales:
    #{details[:additional_details]}

    User Agent: #{details[:user_agent]}
    IP: #{details[:ip]}

    Este es un error automático del sistema de registro de participantes.
  MESSAGE
end

post '/send-mail' do
  unless verify_recaptcha
    flash[:error] = 'Ha ocurrido un error, su mensaje no fué enviado'
    redirect "/#{session[:locale]}#{params[:context]}"
    return
  end

  # Create base data structure first
  base_data = {
    name: params[:name],
    email: params[:email],
    company: params[:company],
    message: params[:message],
    context: params[:context],
    language: session[:locale],
    resource_slug: params[:resource_slug],
    initial_slug: params[:resource_slug],
    can_we_contact: params[:can_we_contact] == 'on',
    suscribe: params[:suscribe] == 'on'
  }
  send_mail(base_data)

  # Send additional resource emails
  additional_resources = params.select { |k, v| k.start_with?('ad-') && v == 'on' }
  additional_resources.each do |key, _|
    resource_slug = key.sub('ad-', '')
    send_mail(base_data.merge(resource_slug: resource_slug))
  end

  flash[:notice] = 'Su mensaje ha sido enviado correctamente'
  redirect "/#{session[:locale]}#{params[:context]}"
end

get '/mailer-template' do
  headers 'X-Robots-Tag' => 'noindex'
  erb :'component/_form_contact', layout: false
end
