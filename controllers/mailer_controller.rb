include Recaptcha::Adapters::ControllerMethods

post "/send-mail" do
  #TODO: Validate and filter params

  puts "verify_recaptcha: #{verify_recaptcha}"

  if verify_recaptcha
    connector = KeventerConnector.new
    connector.send_mail(params)
    flash[:success] = 'Su mensaje ha sido enviado correctamente'
  else
    puts "Error en el captcha"
    flash[:error] = 'Ha ocurrido un error, su mensaje no fué enviado'
  end
  redirect params[:context]
end

