require 'spec_helper'
require './app'

# The old AI-adoption URLs were redirected to a services page that does not
# exist: whoever followed an old link, or came from the search index, landed on
# a 404 and the authority those URLs had went nowhere. The subject lives under
# formación, and that page does exist.
describe 'legacy AI adoption URLs' do
  def app
    Sinatra::Application.new
  end

  # The services route looks the area up before deciding it is not its business;
  # there is no such area, which is the whole point.
  before do
    allow(Page).to receive(:load_from_keventer).and_return(Page.new)
    allow(ServiceAreaV3).to receive(:create_keventer).and_return(nil)
  end

  %w[
    /servicios/adopcion-ia/membresia
    /servicios/adopcion-ia/membresia-ia
    /formacion/adopcion-ia/membresia
  ].each do |old_path|
    it "sends #{old_path} to the page that exists" do
      get old_path

      expect(last_response.status).to eq(301)
      expect(last_response.location).to end_with('/es/formacion/adopcion-ia-empresas')
    end
  end
end
