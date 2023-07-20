include Recaptcha::Adapters::ControllerMethods

post "/send-mail" do
  if verify_recaptcha
    puts "Captcha válido"
    puts params
    connector = KeventerConnector.new
    connector.send_mail(params)
    redirect params[:context]
  else
    puts params
    flash[:error] = 'Ha ocurrido un error, su mensaje no fué enviado'
    redirect params[:context]
  end



  # begin
  #   puts params['_csrf']
  #   puts session[:csrf]
  #   csrf_token = params['_token']
  #   session_token = session[:csrf]

  #   if !(csrf_token == session_token)
  #     flash[:error] = 'Captcha inválido'
  #     # halt 403, 'Acceso denegado'
  #   else
  #     puts 'Captcha válido'
  #   end

  #   connector = KeventerConnector.new
  #   connector.send_mail(params)
  #   redirect params[:context]
  # rescue Exception => e
  #   puts e
  # end

end

