require 'spec_helper'
require './app'

# The flagship catch-all (get '/:slug') must not forward garbage paths to the
# Keventer API: scrapers request quoted strings from our HTML (aria-labels,
# CSS classes) as URLs, and URI.join raises URI::InvalidURIError on them,
# turning what should be a 404 into a 500.
describe 'GET /:slug (flagship catch-all)' do
  def app
    Sinatra::Application.new
  end

  context 'with a non-slug path (bot-extracted attribute text)' do
    it 'returns 404, not 500, for a path with spaces' do
      get '/Contact%20us%20via%20WhatsApp'
      expect(last_response.status).to eq(404)
    end

    it 'returns 404, not 500, for CSS-class-like paths' do
      get '/col-lg-6%20contact__img-container'
      expect(last_response.status).to eq(404)
    end

    it 'does not hit the Keventer API for garbage slugs' do
      expect(Page).not_to receive(:load_from_keventer)
      get '/mb-3%20contact-only-field'
    end
  end

  context 'with a well-formed slug' do
    it 'still consults Page.load_from_keventer' do
      page = instance_double(Page, flagship?: false)
      expect(Page).to receive(:load_from_keventer).with(anything, 'some-page').and_return(page)
      get '/some-page'
      expect(last_response.status).to eq(404) # non-flagship falls through
    end
  end

  # Two URLs for one page, on two hosts, each with its own sitemap. Every
  # subdomain is its own site, so the rule is asked as "main site only".
  %w[lab.kleer.la qa.lab.kleer.la latelier.kleer.la qa.latelier.kleer.la].each do |host|
    context "on #{host}" do
      it 'does not serve the main site pages' do
        expect(Page).not_to receive(:load_from_keventer)

        get '/es/membresia-ia-v2', {}, { 'HTTP_HOST' => host }

        expect(last_response.status).to eq(404)
      end
    end
  end

  # An empty canonical used to render as https://www.kleer.la/es — the language
  # home page — so every flagship page told crawlers it was a duplicate of it.
  context 'canonical' do
    def flagship(canonical)
      instance_double(Page, flagship?: true, canonical: canonical,
                            seo_title: 'Membresía IA', seo_description: 'Una descripción',
                            name: 'Membresía IA', hero_section: nil, contact_section: nil,
                            body_sections: [], recommended: [], cover: nil)
    end

    it 'points a page with no canonical of its own at itself' do
      allow(Page).to receive(:load_from_keventer).and_return(flagship(nil))

      get '/es/membresia-ia-v2'

      expect(last_response.body).to include('<link rel="canonical" href="https://www.kleer.la/es/membresia-ia-v2"/>')
    end

    it 'respects a canonical the page declares, adding the slash it needs' do
      allow(Page).to receive(:load_from_keventer).and_return(flagship('membresia-ia'))

      get '/es/membresia-ia-v2'

      expect(last_response.body).to include('<link rel="canonical" href="https://www.kleer.la/es/membresia-ia"/>')
    end
  end
end
