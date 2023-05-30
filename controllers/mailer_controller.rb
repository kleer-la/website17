
post "/send-mail" do
  puts params['csrf_token']
  csrf_token = params['csrf_token']
  session_token = session[:csrf]

  if !(csrf_token == session_token)
    puts "Captcha inválido"
    flash[:error] = 'Captcha inválido'
    halt 403, 'Acceso denegado'
  else
    puts "Captcha válido"
    connector = KeventerConnector.new
    connector.send_mail(params)
    redirect params[:context]
  end
end

