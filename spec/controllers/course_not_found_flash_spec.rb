require 'spec_helper'
require './app'

# Regression test for #141: the "curso no encontrado" flash must survive the
# redirect to the catalog. It previously used flash.now[:alert] (lost on
# redirect, and :alert is not rendered by the layout), so nothing showed.
describe 'Course not found flash (#141)' do
  include Rack::Test::Methods

  def app
    Sinatra::Application.new
  end

  it 'renders an error flash after redirecting to the catalog' do
    get '/es/cursos/no-existe-este-curso'

    expect(last_response.status).to eq(302)
    follow_redirect!

    expect(last_response).to be_ok
    # The layout maps an :error flash to a Bootstrap alert-danger block; before
    # the fix the catalog page rendered no flash at all.
    expect(last_response.body).to include('alert-danger')
  end
end
