require 'spec_helper'
require 'sinatra/flash'
require './app'

describe 'MyApp' do
  def app
    Sinatra::Application.new
  end

  describe 'POST /send-mail' do
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
  #
  # describe 'POST /formulario' do
  #   it 'debe redirigir correctamente y mostrar un mensaje de agradecimiento' do
  #     post '/formulario', { nombre: 'John', apellido: 'Doe' }
  #     expect(last_response).to be_redirect
  #     follow_redirect!
  #     expect(last_response.body).to include('¡Gracias por completar el formulario, John Doe!')
  #   end
  # end
end


# {"name"=>"prueba", "email"=>"prueba@mail.com", "phone"=>"", "message"=>"Mensaje de prueba", "g-recaptcha-response"=>"invalid captcha response", "context"=>"/"}