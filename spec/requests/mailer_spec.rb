describe 'MyApp' do
  def app
    Sinatra::Application.new
  end

  # describe 'GET /' do
  #   it 'debe cargar la página de inicio correctamente' do
  #     get '/'
  #     expect(last_response).to be_ok
  #     expect(last_response.body).to include('Bienvenido a mi aplicación')
  #   end
  # end

  # describe 'POST /formulario' do
  #   it 'debe redirigir correctamente y mostrar un mensaje de agradecimiento' do
  #     post '/formulario', { nombre: 'John', apellido: 'Doe' }
  #     expect(last_response).to be_redirect
  #     follow_redirect!
  #     expect(last_response.body).to include('¡Gracias por completar el formulario, John Doe!')
  #   end
  # end
end
