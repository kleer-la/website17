require 'spec_helper'
require 'sinatra/flash'
require './app'

describe 'MyApp' do
  def app
    Sinatra::Application.new
  end

  describe 'POST /send-mail' do
    it 'Debe estar configurado Recaptcha' do
      expect(ENV['RECAPTCHA_SITE_KEY']).not_to be_empty
    end
    it 'Debe retornar error' do
      payload = {"name"=>"prueba",
                 "email"=>"prueba@mail.com",
                 "phone"=>"",
                 "message"=>"Mensaje de prueba",
                 "g-recaptcha-response"=>"invalid captcha response", "context"=>"/"}
      post '/send-mail', payload
      expect(last_request.env['rack.session'][:flash][:error]).to match(/Ha ocurrido un error, su mensaje no fué enviado/)
    end
  end
end
