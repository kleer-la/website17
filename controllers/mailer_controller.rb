post "/send-mail" do
  csrf_protect!

  if !recaptcha_valid?
    flash[:error] = 'Captcha inválido'
    redirect back
  else
    connector = KeventerConnector.new
    connector.send_mail(params)
    redirect params[:context]
  end
end

