include Recaptcha::Adapters::ControllerMethods

post "/send-mail" do
  data = {
    name: params[:name],
    email: params[:email],
    phone: params[:phone],
    message: params[:message],
  }

  if verify_recaptcha
    connector = KeventerConnector.new
    connector.send_mail(data)
    puts "Mensaje enviado correctamente"
    flash[:notice] = 'Su mensaje ha sido enviado correctamente'
  else
    puts "Error en el captcha"
    flash[:error] = 'Ha ocurrido un error, su mensaje no fué enviado'
  end
  redirect params[:context]
end

