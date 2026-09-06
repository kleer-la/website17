require 'spec_helper'
require './app'

# The old category URLs sent the visitor to /cursos/<slug>, without a language.
# That namespace answers 200 and then declares /es/cursos/<slug> as its
# canonical, so the redirect stopped one URL short of the page it meant.
describe 'legacy category course URLs' do
  def app
    Sinatra::Application.new
  end

  it 'sends the old category URL to the Spanish course URL' do
    get '/categoria/desarrollo-profesional/cursos/7-certified-scrum-master-csm'

    expect(last_response.status).to eq(301)
    expect(last_response.location).to end_with('/es/cursos/7-certified-scrum-master-csm')
  end
end
