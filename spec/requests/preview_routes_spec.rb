require 'spec_helper'
require './app'

# A preview shows content nobody has decided to publish yet: draft news, an
# unreviewed resource, a training area half written. The canonical points at the
# real page, but a canonical is a suggestion — this site's index report already
# has eleven pages where Google either picked a different one or picked none.
# /blog-preview has said noindex since it was written; the rest never did.
describe 'preview routes' do
  def app
    Sinatra::Application.new
  end

  let(:area_data) do
    { 'id' => 1, 'slug' => 'adopcion-ia-empresas', 'name' => 'Adopción de IA', 'lang' => 'es',
      'is_training_program' => true, 'primary_color' => '#FF5733', 'primary_font_color' => '#FFFFFF',
      'secondary_color' => '#33FF57', 'secondary_font_color' => '#000000', 'services' => [] }
  end

  before do
    allow(Page).to receive(:load_from_keventer).and_return(Page.new)
    allow(News).to receive(:create_list_keventer).and_return([])
    allow(Resource).to receive(:create_list_keventer).and_return([])
    allow(Article).to receive(:create_list_keventer).and_return([])
    ServiceAreaV3.null_json_api(nil, NullJsonAPI.new(nil, area_data.to_json))
  end

  after do
    ServiceAreaV3.class_variable_set(:@@json_api, nil) if ServiceAreaV3.class_variable_defined?(:@@json_api)
  end

  %w[
    /es/novedades/preview
    /es/recursos/preview
    /es/formacion/adopcion-ia-empresas/preview
    /es/blog-preview
  ].each do |path|
    it "keeps #{path} out of the index" do
      get path

      expect(last_response.status).to eq 200
      expect(last_response.body).to include('<meta name="robots" content="noindex,nofollow"/>')
    end
  end

  # The published page it previews must not pick the directive up.
  it 'leaves the real page indexable' do
    get '/es/novedades'

    expect(last_response.body).not_to include('name="robots"')
  end
end
