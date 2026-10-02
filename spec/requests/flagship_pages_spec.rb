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

        get '/es/some-flagship', {}, { 'HTTP_HOST' => host }

        expect(last_response.status).to eq(404)
      end
    end
  end

  # A flagship page can be published and still not belong in the index: the
  # preview of a page that has not replaced the live one yet. Without the flag
  # the preview was the only indexable copy of content whose real page is
  # deliberately noindex.
  context 'noindex' do
    def flagship(noindex)
      instance_double(Page, flagship?: true, canonical: nil, noindex: noindex,
                            seo_title: 'Membresía IA', seo_description: 'Una descripción',
                            name: 'Membresía IA', hero_section: nil, contact_section: nil,
                            body_sections: [], recommended: [], cover: nil)
    end

    it 'keeps a page marked noindex out of the results' do
      allow(Page).to receive(:load_from_keventer).and_return(flagship(true))

      get '/es/some-flagship'

      expect(last_response.body).to include('<meta name="robots" content="noindex"/>')
    end

    it 'says nothing about robots for a page that is not marked' do
      allow(Page).to receive(:load_from_keventer).and_return(flagship(false))

      get '/es/some-flagship'

      expect(last_response.body).not_to include('name="robots"')
    end
  end

  # An empty canonical used to render as https://www.kleer.la/es — the language
  # home page — so every flagship page told crawlers it was a duplicate of it.
  context 'canonical' do
    def flagship(canonical)
      instance_double(Page, flagship?: true, canonical: canonical, noindex: false,
                            seo_title: 'Membresía IA', seo_description: 'Una descripción',
                            name: 'Membresía IA', hero_section: nil, contact_section: nil,
                            body_sections: [], recommended: [], cover: nil)
    end

    it 'points a page with no canonical of its own at itself' do
      allow(Page).to receive(:load_from_keventer).and_return(flagship(nil))

      get '/es/some-flagship'

      expect(last_response.body).to include('<link rel="canonical" href="https://www.kleer.la/es/some-flagship"/>')
    end

    it 'respects a canonical the page declares, adding the slash it needs' do
      allow(Page).to receive(:load_from_keventer).and_return(flagship('membresia-ia'))

      get '/es/some-flagship'

      expect(last_response.body).to include('<link rel="canonical" href="https://www.kleer.la/es/membresia-ia"/>')
    end
  end

  def flagship_page(sections: [], recommended: [])
    Page.new('name' => 'Membresía IA', 'lang' => 'es', 'template' => 'flagship',
             'sections' => sections, 'recommended' => recommended)
  end

  def hero(cta_url)
    { 'slug' => 'hero', 'title' => 'Membresía', 'content' => '<h2>Titular</h2>',
      'cta_text' => 'Agendar una conversación', 'cta_url' => cta_url, 'position' => 1 }
  end

  # Areas show what Keventer recommends next to them; a flagship loaded the
  # list and dropped it.
  context 'recommended content' do
    it 'shows what the page recommends, before the contact banner' do
      allow(Page).to receive(:load_from_keventer).and_return(
        flagship_page(recommended: [{ 'type' => 'article', 'title' => 'Un artículo recomendado',
                                      'slug' => 'un-articulo', 'lang' => 'es', 'cover' => '' }])
      )

      get '/es/some-flagship'

      body = last_response.body
      expect(body).to include('Un artículo recomendado')
      expect(body.index('recommendedContent')).to be < body.index('newsletter-subscription')
    end

    it 'shows no recommended block when there is nothing to recommend' do
      allow(Page).to receive(:load_from_keventer).and_return(flagship_page)

      get '/es/some-flagship'

      expect(last_response.body).not_to include('recommendedContent')
    end
  end

  # The written membership page opened the contact form from its hero; the
  # flagship could only link or jump to an anchor.
  context 'hero button' do
    ['', nil, '#contact', '#newsletter-subscription'].each do |cta_url|
      it "opens the contact form when the button points at the contact (#{cta_url.inspect})" do
        allow(Page).to receive(:load_from_keventer).and_return(flagship_page(sections: [hero(cta_url)]))

        get '/es/some-flagship'

        hero_html = last_response.body[/<section class="flagship-hero">.*?<\/section>/m]
        expect(hero_html).to include('data-bs-target="#mail-modal"')
        expect(hero_html).to include('Agendar una conversación')
      end
    end

    it 'keeps any other address as a link' do
      allow(Page).to receive(:load_from_keventer).and_return(flagship_page(sections: [hero('/es/cursos')]))

      get '/es/some-flagship'

      hero_html = last_response.body[/<section class="flagship-hero">.*?<\/section>/m]
      expect(hero_html).to include('href="/es/cursos"')
      expect(hero_html).not_to include('#mail-modal')
    end
  end

  # The membership page was written twice: a view in this repo and a flagship
  # in Keventer. Marketing edits the flagship, so it takes the URL.
  context 'membresia-ia' do
    it 'is the flagship with that slug' do
      expect(Page).to receive(:load_from_keventer).with('es', 'membresia-ia')
                                                  .and_return(flagship_page(sections: [hero('#contact')]))

      get '/es/membresia-ia'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('flagship-hero')
    end

    it 'has no English page while there is no English flagship (#399)' do
      allow(Page).to receive(:load_from_keventer).with('en', 'membresia-ia').and_return(Page.new)

      get '/en/membresia-ia'

      expect(last_response.status).to eq(404)
    end

    it 'sends the preview URL to the page it became' do
      get '/es/membresia-ia-v2'

      expect(last_response.status).to eq(301)
      expect(last_response.location).to end_with('/es/membresia-ia')
    end
  end
end
