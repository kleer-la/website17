require 'spec_helper'
require './app'

# Google Tag Manager (GTM-W5H5CPKF) counts the Ads and GA4 conversions with
# triggers that match page details: the WhatsApp button's id and the forms'
# ids. Renaming one breaks nothing visible; the conversion just stops being
# counted. This spec is our side of that contract (#471): change it together
# with marketing, who edit the container.
describe 'what the GTM container relies on' do
  def app
    Sinatra::Application.new
  end

  let(:gtm_id) { 'GTM-W5H5CPKF' }

  let(:area) do
    ServiceAreaV3.new.load_from_json(
      JSON.parse(File.read('spec/fixtures/headings/area_producto_digital.json')).merge('ordering' => 10)
    )
  end

  let(:course) do
    EventType.new({ 'id' => 7, 'slug' => '7-csm', 'canonical_slug' => '7-csm', 'name' => 'CSM', 'lang' => 'es',
                    'deleted' => false, 'noindex' => false, 'elevator_pitch' => 'Scrum', 'categories' => [],
                    'trainers' => [], 'description' => 'Un curso.', 'program' => 'Flujo', 'faq' => '' })
  end

  let(:resource) do
    doc = JSON.parse(File.read('./spec/fixtures/resource_concepts.json'))
              .merge('slug' => 'cartas', 'format' => 'card', 'concepts' => [], 'authors' => [])
    Resource.new(doc, 'es')
  end

  before do
    CacheService.instance.clear
    Toggle.turn(:services_redesign, true)
    allow(Page).to receive(:load_from_keventer).and_return(Page.new)
    allow(Event).to receive(:create_keventer_json).and_return([])
    allow(ServiceAreaV3).to receive_messages(try_create_list_keventer: [area], create_keventer: area)
    allow(EventType).to receive(:create_keventer_json).and_return(course)
    allow(Resource).to receive(:create_one_keventer).and_return(resource)
  end

  after { Toggle.turn(:services_redesign, false) }

  def expect_element(page, css, why)
    expect(page.at_css(css)).not_to be_nil, "#{css} is missing: #{why}"
  end

  def page_at(path)
    get path
    expect(last_response.status).to eq 200
    Nokogiri::HTML5(last_response.body)
  end

  pages = {
    'home' => '/es/',
    'a service area' => '/es/servicios/producto-digital',
    'a course' => '/es/cursos/7-csm',
    'a resource' => '/es/recursos/cartas'
  }

  pages.each do |name, path|
    describe name do
      it 'loads the GTM container once, with its noscript fallback, and no other Google tag' do
        page = page_at(path)
        html = last_response.body

        expect(html.scan("'#{gtm_id}'").size).to eq(1), "the GTM snippet must be in the page once (#{path})"
        expect(page.css("noscript iframe[src*='ns.html?id=#{gtm_id}']").size).to eq 1
        expect(html).not_to match(%r{googletagmanager\.com/gtag/js}),
                            'GA4 and Ads are configured in GTM; a hardcoded gtag would count everything twice'
        expect(html).not_to match(/\b(?:G|AW)-[A-Z0-9]{6,}\b/), 'tag ids belong in the GTM container, not the site'
      end

      it 'keeps the WhatsApp button and the contact form the conversions are counted from' do
        page = page_at(path)

        expect_element(page, '#whatsapp-button', 'the WhatsApp conversion matches this click id')
        expect_element(page, 'form#contact-form', 'the contact conversions match this form id')
      end
    end
  end

  it 'keeps the in-company quote form on a course page' do
    expect_element(page_at('/es/cursos/7-csm'), 'form#incompany-quote-form', 'the quote conversion matches this id')
  end

  it 'keeps the download form on a resource page' do
    expect_element(page_at('/es/recursos/cartas'), 'form#download-form', 'the download conversion matches this id')
  end
end
