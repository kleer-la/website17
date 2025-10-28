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
    puts "Failed to send error notification email: #{e.message}" unless ENV['RACK_ENV'] == 'test'
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
    flash[:error] = t('mailer.error')
    redirect "/#{session[:locale]}#{params[:context]}"
    return
  end

  # Check if this is an incompany quote form
  if params[:form_type] == 'incompany_quote'
    # Build incompany quote message
    message = build_incompany_quote_message(params)

    base_data = {
      name: params[:name],
      email: params[:email],
      company: params[:company],
      message: message,
      context: params[:context],
      language: session[:locale],
      resource_slug: '',
      initial_slug: '',
      can_we_contact: false,
      suscribe: false
    }
    send_mail(base_data)
  else
    # Original contact form logic
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
    additional_resources.each_key do |key|
      resource_slug = key.sub('ad-', '')
      send_mail(base_data.merge(resource_slug: resource_slug))
    end
  end

  flash[:notice] = t('mailer.success')
  redirect "/#{session[:locale]}#{params[:context]}"
end

def build_incompany_quote_message(params)
  location = if params[:location] == 'presencial'
               "#{t('incompany_quote_form.location_onsite')} - #{params[:where]}"
             else
               t('incompany_quote_form.location_online')
             end

  when_date = begin
    Date.strptime(params[:when], '%Y-%m').strftime('%B %Y')
  rescue StandardError
    params[:when]
  end

  <<~MESSAGE
    #{t('incompany_quote_form.title')}

    #{t('incompany_quote_form.location_label')}: #{location}
    #{t('incompany_quote_form.when_label')}: #{when_date}
    #{t('incompany_quote_form.attendees_label')}: #{params[:attendees]}
  MESSAGE
end

get '/mailer-template' do
  headers 'X-Robots-Tag' => 'noindex'
  erb :'component/_form_contact', layout: false
end
