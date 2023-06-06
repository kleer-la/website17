
post "/send-mail" do
  begin
    puts params['_csrf']
    puts session[:csrf]
    csrf_token = params['_token']
    session_token = session[:csrf]

    if !(csrf_token == session_token)
      flash[:error] = 'Captcha inválido'
      halt 403, 'Acceso denegado'
    else
      puts 'Captcha válido'
    end

    connector = KeventerConnector.new
    connector.send_mail(params)
    redirect params[:context]
  rescue Exception => e
    puts e
  end

end

