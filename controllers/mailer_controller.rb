post "/send-mail" do
  connector = KeventerConnector.new
  connector.send_mail(params)
  redirect params[:context]
end

