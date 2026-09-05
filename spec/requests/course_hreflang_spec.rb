require 'spec_helper'
require './app'

# A course exists in one language: there is a Spanish event type and, when it is
# offered in English, a separate English one. The page used to declare the other
# language anyway, building the URL with the Spanish segment under /en — a URL
# that redirects to the catalogue. All 34 courses pointed at that same catalogue,
# so the alternates never pointed back and the whole cluster was discarded.
describe 'GET /:lang/cursos/:slug — language alternates' do
  def app
    Sinatra::Application.new
  end

  # The slug carries the id: the URL is the slug, so anything else redirects.
  def stub_course(lang:, slug: '7-certified-scrum-master-csm', id: 7)
    EventType.new({
                    'id' => id, 'slug' => slug, 'name' => 'Certified Scrum Master (CSM)',
                    'lang' => lang, 'deleted' => false, 'noindex' => false,
                    'elevator_pitch' => 'Aprendé Scrum', 'canonical_slug' => slug,
                    'categories' => [], 'faq' => '', 'trainers' => []
                  })
  end

  context 'a course given in Spanish' do
    before { allow(EventType).to receive(:create_keventer_json).and_return(stub_course(lang: 'es')) }

    it 'declares Spanish and nothing else' do
      get '/es/cursos/7-certified-scrum-master-csm'

      expect(last_response.body).to include('hreflang="es"')
      expect(last_response.body).not_to include('hreflang="en"')
    end

    it 'does not send anyone to the Spanish path under /en' do
      get '/es/cursos/7-certified-scrum-master-csm'

      expect(last_response.body).not_to include('/en/cursos/')
    end
  end

  context 'a course given in English' do
    before { allow(EventType).to receive(:create_keventer_json).and_return(stub_course(lang: 'en')) }

    it 'declares English, and x-default agrees with it' do
      get '/en/courses/7-certified-scrum-master-csm'

      expect(last_response.body).to include('hreflang="en"')
      expect(last_response.body).not_to include('hreflang="es"')
      expect(last_response.body).to include(%(hreflang='x-default' href="https://www.kleer.la/en/courses/))
    end
  end
end
