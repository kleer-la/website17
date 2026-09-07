require 'spec_helper'
require './app'

# A resource exists in one language unless its translation really is there.
# Forty-five of the forty-five Spanish resources offered /en/resources/<slug>,
# and only five of those answer: the rest send the crawler to the index, and an
# alternate that does not answer back is a pair Google never confirms.
describe 'language alternates of a resource' do
  include Rack::Test::Methods

  def app
    Sinatra::Application.new
  end

  def resource_double(slug:, title:)
    double('Resource', slug: slug, title: title, tabtitle: title, seo_description: '', cover: '',
                       long_description: '', :long_description= => '', also_download: [], format: 'pdf',
                       landing: '', description: '', comments: '', getit: '', assessment_id: nil,
                       preview: '', lang: 'es', author_trainers: [], trainers_with_role: [],
                       recommended_not_downloads: [])
  end

  before do
    allow(Page).to receive(:load_from_keventer).and_return(Page.new)
    allow(Resource).to receive(:create_one_keventer).with('poster-scrum', 'es')
                                                    .and_return(resource_double(slug: 'poster-scrum',
                                                                                title: 'Poster Scrum'))
  end

  context 'when the resource has no version in the other language' do
    before do
      allow(Resource).to receive(:create_one_keventer).with('poster-scrum', 'en')
                                                      .and_return(resource_double(slug: 'poster-scrum', title: ''))
    end

    it 'declares the language it has and no other' do
      get '/es/recursos/poster-scrum'

      expect(last_response.body).to include('hreflang="es" href="https://www.kleer.la/es/recursos/poster-scrum"')
      expect(last_response.body).not_to include('hreflang="en"')
    end
  end

  context 'when the resource is translated' do
    before do
      allow(Resource).to receive(:create_one_keventer).with('poster-scrum', 'en')
                                                      .and_return(resource_double(slug: 'scrum-poster',
                                                                                  title: 'Scrum Poster'))
    end

    it 'declares both, each at the slug it has' do
      get '/es/recursos/poster-scrum'

      expect(last_response.body).to include('hreflang="es" href="https://www.kleer.la/es/recursos/poster-scrum"')
      expect(last_response.body).to include('hreflang="en" href="https://www.kleer.la/en/resources/scrum-poster"')
    end
  end
end
