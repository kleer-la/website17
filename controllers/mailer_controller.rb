require './lib/json_api'
require './lib/services/mailer'

include Recaptcha::Adapters::ControllerMethods

def send_mail(data)
  url = data[:resource_slug] && !data[:resource_slug].empty? ? KeventerAPI.contacts_url : KeventerAPI.mailer_url
  # return JSON.parse(@response) unless @response.nil? # NullInfra -esque
  Mailer.new(url, data)
end

post '/send-mail' do
  data = {
    name: params[:name],
    email: params[:email],
    phone: params[:phone],
    message: params[:message],
    context: params[:context],
    resource_slug: params[:resource_slug],
    language: session[:locale]
  }

  if verify_recaptcha
    send_mail(data)

    flash[:notice] = 'Su mensaje ha sido enviado correctamente'
  else
    flash[:error] = 'Ha ocurrido un error, su mensaje no fué enviado'
  end
  redirect "/#{session[:locale]}#{params[:context]}"
end

get '/mailer-template' do
  headers 'X-Robots-Tag' => 'noindex'

  erb :'component/_form_contact', layout: false
end
