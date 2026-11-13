require 'spec_helper'
require './app'
require './lib/heading_outline'

# The pages search engines rank us on, rendered from Keventer content shaped like
# production's, checked as the outline of headings they read (see HeadingOutline).
describe 'the heading outline of the main pages' do
  def app
    Sinatra::Application.new
  end

  def area_json
    JSON.parse(File.read('spec/fixtures/headings/area_producto_digital.json'))
  end

  def area(hash = area_json.merge('ordering' => 10))
    ServiceAreaV3.new.load_from_json(hash)
  end

  def outline_problems(path)
    get path
    expect(last_response.status).to eq 200
    HeadingOutline.new(last_response.body).problems.map(&:to_s)
  end

  def expect_sound_outline(path)
    problems = outline_problems(path)
    expect(problems).to be_empty, "#{problems.size} heading problems on #{path}:\n  #{problems.join("\n  ")}"
  end

  # A training programme ordered before the areas goes inside their section;
  # ordered after them, it gets a section of its own.
  let(:featured_ordering) { 1 }
  let(:featured_program) do
    area('ordering' => featured_ordering, 'slug' => 'adopcion-organizacional-ia',
         'name' => 'Adopción Organizacional de IA', 'lang' => 'es', 'is_training_program' => true,
         'primary_color' => '#FF5733', 'services' => [])
  end

  before do
    CacheService.instance.clear
    Toggle.turn(:services_redesign, true)
    allow(Page).to receive(:load_from_keventer).and_return(Page.new)
    allow(Event).to receive(:create_keventer_json).and_return([])
    other_area = area(area_json.merge('ordering' => 20, 'slug' => 'cambio', 'name' => 'Cambio'))
    allow(ServiceAreaV3).to receive(:try_create_list_keventer) do |programs = false|
      programs ? [featured_program] : [area, other_area]
    end
    allow(ServiceAreaV3).to receive(:create_keventer) do |slug|
      slug == featured_program.slug ? featured_program : area
    end
  end

  after { Toggle.turn(:services_redesign, false) }

  describe 'home' do
    it 'with the featured programme inside the areas section' do
      expect_sound_outline('/es/')
    end

    context 'when the featured programme comes after the areas' do
      let(:featured_ordering) { 99 }

      it 'gives it a section of its own, titled h2' do
        expect_sound_outline('/es/')
        expect(Nokogiri::HTML5(last_response.body).at_css('section > .featured-program h2').text)
          .to eq 'Adopción Organizacional de IA'
      end
    end
  end

  it 'services' do
    expect_sound_outline('/es/servicios')
  end

  it 'service area' do
    expect_sound_outline('/es/servicios/producto-digital')
  end

  # Outcomes, program and FAQ are sections of the v2 pages, whatever the content does.
  it 'titles the outcomes, program and FAQ blocks as sections, with their items one level below' do
    with_blocks = area_json.merge('ordering' => 10, 'outcomes' => ['Menos retrabajo'],
                                  'program' => [['Diagnóstico', 'Dos semanas para acordar por dónde empezar']])
    allow(ServiceAreaV3).to receive(:create_keventer).and_return(area(with_blocks))
    get '/es/servicios/producto-digital'
    page = Nokogiri::HTML5(last_response.body)

    expect(page.css('.offering-title').map(&:name)).to eq %w[h2 h2 h2]
    expect(page.css('.program-item__title, .faq .accordion-header').map(&:name).uniq).to eq %w[h3]
  end

  it 'service' do
    expect_sound_outline('/es/servicios/producto-digital/estrategia-product-management')
  end

  it 'catalog' do
    courses = [{ 'event_type_id' => 1, 'slug' => '1-scrum', 'name' => 'Scrum', 'lang' => 'es', 'categories' => [] },
               { 'event_type_id' => 2, 'slug' => '2-kanban', 'name' => 'Kanban', 'lang' => 'es', 'categories' => [] }]
    allow(Catalog).to receive(:create_keventer_json).and_return(Catalog.load_catalog_events(courses))
    allow(Category).to receive(:create_keventer_json).and_return([])

    expect_sound_outline('/es/catalogo')
  end

  # The hero's tagline and the quote form's field groups are not sections (#466).
  it 'course' do
    allow(EventType).to receive(:create_keventer_json).and_return(
      EventType.new({ 'id' => 7, 'slug' => '7-csm', 'canonical_slug' => '7-csm', 'name' => 'CSM', 'lang' => 'es',
                      'deleted' => false, 'noindex' => false, 'elevator_pitch' => 'Scrum', 'categories' => [],
                      'trainers' => [], 'subtitle' => 'Aprendé Scrum haciendo',
                      'description' => "## Qué es\n\nUn curso.", 'takeaways' => 'Mucho', 'recipients' => 'Equipos',
                      'program' => "#### Kanban\n\nFlujo visible", 'faq' => "#### ¿Cuánto dura?\n\nDos días." })
    )

    expect_sound_outline('/es/cursos/7-csm')
  end

  describe 'with an author' do
    let(:author) do
      { 'id' => 7, 'name' => 'Ana Autora', 'bio' => 'Facilita equipos.', 'gravatar_email' => 'ana@example.com' }
    end

    # The table of contents is navigation, ahead of the article's own h2s (#467).
    it 'article' do
      article = Article.new('id' => 1, 'title' => 'Un artículo', 'slug' => 'un-articulo', 'lang' => 'es',
                            'published' => true, 'description' => 'desc', 'trainers' => [author],
                            'body' => '<h2>Primero</h2><p>Texto</p><h3>Detalle</h3><h2>Segundo</h2><p>Más</p>')
      allow(Article).to receive_messages(create_one_keventer: article, create_list_keventer: [])

      expect_sound_outline('/es/blog/un-articulo')
    end

    # As a heading it would adopt an article that starts with h3, and hide that
    # skip: it is a labelled nav, so the outline reports the article itself.
    it 'article whose body starts below h2' do
      article = Article.new('id' => 1, 'title' => 'Un artículo', 'slug' => 'un-articulo', 'lang' => 'es',
                            'published' => true, 'description' => 'desc', 'trainers' => [],
                            'body' => '<h3>Primero</h3><p>Texto</p>')
      allow(Article).to receive_messages(create_one_keventer: article, create_list_keventer: [])

      expect(outline_problems('/es/blog/un-articulo'))
        .to eq ['h3 «Primero» comes right after h1 «Un artículo», skipping a level']
      toc = Nokogiri::HTML5(last_response.body).at_css('nav#landing-blog-content-table')
      expect(toc.at_css("##{toc['aria-labelledby']}").text).to eq 'Tabla de contenido'
    end

    it 'resource' do
      doc = JSON.parse(File.read('./spec/fixtures/resource_concepts.json'))
                .merge('slug' => 'cartas', 'format' => 'card', 'concepts' => [], 'authors' => [author])
      allow(Resource).to receive(:create_one_keventer).and_return(Resource.new(doc, 'es'))

      expect_sound_outline('/es/recursos/cartas')
    end
  end

  # The pages below had their headings out of place in production (#466).
  describe 'listings' do
    # The hero's tagline is not a section: as an h2 it adopted every article card.
    it 'English blog' do
      article = double('article', slug: 'kards', title: 'DoR Kards', description: 'A game.', cover: '/img/x.png',
                                  category_name: 'Teams', lang: 'en', selected: false, trainers: [],
                                  substantive_change_at: '2025-09-30T10:00:00Z', noindex: false, tabtitle: 'x',
                                  categories: [])
      allow(Article).to receive(:create_list_keventer).and_return([article])
      allow(Category).to receive(:create_keventer_json).and_return([])

      expect_sound_outline('/en/blog')
    end

    # Each member's name ranks right below the team's h2.
    it 'about us' do
      kleerer = Trainer.new('es').load_from_json('id' => 1, 'name' => 'Ana Kleerer', 'bio' => 'Facilita.',
                                                 'gravatar_email' => 'ana@example.com', 'is_kleerer' => true,
                                                 'linkedin_url' => '', 'twitter_username' => '')
      allow(Trainer).to receive(:create_keventer_json).and_return([kleerer])

      expect_sound_outline('/es/somos')
    end

    # The case cards come right after the page's h1.
    it 'clients' do
      case_study = double('article', slug: 'caso', title: 'Un caso', cover: '/img/x.png', lang: 'es',
                                     industry: 'technology', created_at: '2026-01-01')
      allow(Article).to receive(:create_list_keventer).and_return([case_study])

      expect_sound_outline('/es/clientes')
    end

    # So do the news cards.
    it 'news' do
      news = News.new('id' => 1, 'title' => 'Webinar', 'description' => 'Un encuentro.', 'lang' => 'es',
                      'event_date' => '2026-10-01', 'trainers' => [])
      allow(News).to receive(:create_list_keventer).and_return([news])

      expect_sound_outline('/es/novedades')
    end

    # With no editions scheduled the agenda offers academy and catalog courses:
    # each group is a section of its own, and the hero's tagline is not one.
    it 'agenda with nothing scheduled' do
      courses = [{ 'event_type_id' => 1, 'slug' => '1-kata', 'name' => 'Kata', 'lang' => 'es', 'categories' => [],
                   'platform' => 'academia' },
                 { 'event_type_id' => 2, 'slug' => '2-scrum', 'name' => 'Scrum', 'lang' => 'es', 'categories' => [],
                   'platform' => 'keventer' }]
      allow(Catalog).to receive(:create_keventer_json).and_return(Catalog.load_catalog_events(courses))

      expect_sound_outline('/es/agenda')
      expect(Nokogiri::HTML5(last_response.body).css('#academia-courses h2, #catalog-courses h2').size).to eq 2
    end
  end

  # The search results line is a status, not the title of the list (#466).
  it 'resources' do
    doc = JSON.parse(File.read('./spec/fixtures/resource_concepts.json'))
    resources = Resource.load_list([doc, doc.merge('slug' => 'otro')])
    allow(Resource).to receive(:create_list_keventer).and_return(resources)

    expect_sound_outline('/es/recursos')
  end
end
