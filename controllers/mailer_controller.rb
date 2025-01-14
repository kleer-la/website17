require './lib/json_api'
require './lib/services/mailer'

include Recaptcha::Adapters::ControllerMethods

def send_mail(data)
  url = data[:resource_slug] && !data[:resource_slug].empty? ? KeventerAPI.contacts_url : KeventerAPI.mailer_url
  # return JSON.parse(@response) unless @response.nil? # NullInfra -esque
  Mailer.new(url, data)
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
