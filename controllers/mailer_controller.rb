include Recaptcha::Adapters::ControllerMethods

post "/send-mail" do
  data = {
    name: params[:name],
    email: params[:email],
    phone: params[:phone],
    message: params[:message],
    context: params[:context]
  }

  if verify_recaptcha
    connector = KeventerConnector.new
    connector.send_mail(data)
    flash[:notice] = 'Su mensaje ha sido enviado correctamente'

  else
    flash[:error] = 'Ha ocurrido un error, su mensaje no fué enviado'
  end
  redirect params[:context]
end

get "/mailer-template" do
  erb :'component/_form_contact', layout: false
end

