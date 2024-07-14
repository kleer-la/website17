require './lib/json_api'
require './lib/services/mailer'

include Recaptcha::Adapters::ControllerMethods

def send_mail(data)
  url = KeventerAPI.contact_us_url
  # return JSON.parse(@response) unless @response.nil? # NullInfra -esque
  Mailer.new(url, data)
end

post "/send-mail" do
  data = {
    name: params[:name],
    email: params[:email],
    phone: params[:phone],
    message: params[:message],
    context: params[:context]
  }

  if verify_recaptcha
    send_mail(data)

    flash[:notice] = 'Su mensaje ha sido enviado correctamente'
  else
    flash[:error] = 'Ha ocurrido un error, su mensaje no fué enviado'
  end
  redirect params[:context]
end

get "/mailer-template" do
  @meta_tags.set! noindex: true, nofollow: true

  erb :'component/_form_contact', layout: false
end

