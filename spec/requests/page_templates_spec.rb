require 'spec_helper'
require './app'

# Keventer warns whoever edits an overlay page about a section its template
# never reads (kleer-la/eventer#243), from the list PageTemplates declares. That
# list is only worth trusting if it is what the views actually read: these
# render every template and compare.
describe 'what each overlay template reads' do
  def app
    Sinatra::Application.new
  end

  # Where each template renders. A slug can serve several routes, and what it
  # reads is the union.
  let(:routes) do
    {
      nil => ['/es/'],
      'novedades' => ['/es/novedades'],
      'agenda' => ['/es/agenda'],
      'services-landing' => ['/es/servicios'],
      'service-area' => ['/es/servicios/cambio-organizacional',
                         '/es/servicios/cambio-organizacional/diseno-organizacional'],
      'clientes' => ['/es/clientes'],
      'recursos' => ['/es/recursos'],
      'blog' => ['/es/blog'],
      'somos' => ['/es/somos'],
      'podcasts' => ['/es/podcasts'],
      'catalogo' => ['/es/catalogo'],
      'llms' => ['/llms.txt']
    }
  end

  let(:area) do
    { 'id' => 3, 'slug' => 'cambio-organizacional', 'name' => 'Cambio Organizacional', 'lang' => 'es',
      'is_training_program' => false, 'primary_color' => '#4dd3e8', 'primary_font_color' => '#FFFFFF',
      'secondary_color' => '#34e3ff', 'secondary_font_color' => '#000000', 'summary' => 'Resumen',
      'slogan' => 'Slogan', 'subtitle' => 'Bajada', 'description' => 'Descripción', 'services' => [
        { 'id' => 6, 'slug' => 'diseno-organizacional', 'name' => 'Diseño Organizacional',
          'subtitle' => 'Bajada', 'outcomes' => [], 'program' => [], 'faq' => [], 'recommended' => [] }
      ] }
  end

  before do
    CacheService.clear
    # Whatever is not stubbed below finds Keventer empty: these render offline.
    allow(Faraday).to receive(:get).and_return(instance_double(Faraday::Response, status: 200, body: '[]'))
    allow(Page).to receive(:flagships).and_return([])
    allow(News).to receive(:create_list_keventer).and_return([])
    allow(Podcast).to receive(:load_from_keventer).and_return([])
    # No course scheduled, so the agenda shows its empty state and reads it.
    allow(Event).to receive(:create_keventer_json).and_return([])
    allow(Catalog).to receive(:create_keventer_json).and_return(
      Catalog.load_catalog_events([{ 'event_type_id' => 1, 'slug' => '1-scrum', 'name' => 'Scrum',
                                     'lang' => 'es', 'categories' => [] }])
    )
    allow(ServiceAreaV3).to receive(:try_create_list_keventer).and_return([])
    allow(ServiceAreaV3).to receive(:create_keventer).and_return(nil)
    allow(ServiceAreaV3).to receive(:create_keventer).with('cambio-organizacional')
                                                     .and_return(ServiceAreaV3.new.load_from_json(area))
    allow(Category).to receive(:create_keventer_json).and_return([])
  end

  after { CacheService.clear }

  # The section slugs a template reads while rendering its routes.
  def reads_of(slug)
    reads = Set.new
    allow(Page).to receive(:load_from_keventer) { |_lang, loaded| spied_page(loaded == slug ? reads : Set.new) }

    routes.fetch(slug).each do |path|
      get path
      expect(last_response.status).to eq(200), "#{path} answered #{last_response.status}"
    end
    reads
  end

  # An empty page that notes in `reads` every section asked of it.
  def spied_page(reads)
    Page.new.tap do |page|
      allow(page).to(receive(:section).and_wrap_original { |original, key| original.call(key).tap { reads << key } })
    end
  end

  PageTemplates::SECTIONS.each do |slug, sections|
    it "reads exactly the sections declared for #{slug.inspect}" do
      expect(reads_of(slug).to_a).to match_array(sections.keys)
    end
  end

  it 'declares every overlay a controller loads, and renders each one here' do
    loaded = Dir['controllers/*.rb'].flat_map do |file|
      File.read(file).scan(/Page\.load_from_keventer\([^,]+,\s*(nil|'[^']+')\)/).flatten
    end
    slugs = loaded.uniq.map { |s| s == 'nil' ? nil : s.delete("'") }

    expect(PageTemplates::SECTIONS.keys).to match_array(slugs)
    expect(routes.keys).to match_array(slugs)
  end

  # A view that reads the hash directly is one this spec cannot see.
  it 'reads overlay sections only through Page#section' do
    direct = Dir['views/**/*.erb'].reject { |f| f.start_with?('views/flagships/') }.select do |file|
      File.read(file).match?(/\.sections(&?\.dig|\[)/)
    end

    expect(direct).to be_empty
  end

  it 'publishes the list for Keventer' do
    get '/page-templates.json'

    expect(last_response.content_type).to include('application/json')
    templates = JSON.parse(last_response.body)['templates']
    expect(templates).to include({ 'slug' => 'novedades', 'sections' => PageTemplates::SECTIONS['novedades'] })
    expect(templates.find { |t| t['slug'].nil? }['sections'].keys).to include('hero', 'contact')
  end
end
