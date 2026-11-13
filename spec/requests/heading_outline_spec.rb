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

  # The search results line is a status, not the title of the list (#466).
  it 'resources' do
    doc = JSON.parse(File.read('./spec/fixtures/resource_concepts.json'))
    resources = Resource.load_list([doc, doc.merge('slug' => 'otro')])
    allow(Resource).to receive(:create_list_keventer).and_return(resources)

    expect_sound_outline('/es/recursos')
  end
end
