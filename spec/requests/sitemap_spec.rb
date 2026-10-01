require 'spec_helper'
require './app'
require 'nokogiri'

describe 'GET /sitemap.xml' do
  def app
    Sinatra::Application.new
  end

  before do
    allow(Article).to receive(:create_list_keventer).and_return([])
    allow(ServiceAreaV3).to receive(:try_create_list_keventer).and_return([])
    allow(Catalog).to receive(:create_keventer_json).and_return([])
    allow(Resource).to receive(:create_list_keventer).and_return([])
  end

  def sitemap_xml
    Nokogiri::XML(last_response.body)
  end

  def urls
    doc = sitemap_xml
    doc.remove_namespaces!
    doc.xpath('//url/loc').map(&:text)
  end

  it 'returns XML with correct content type' do
    get '/sitemap.xml'

    expect(last_response.status).to eq(200)
    expect(last_response.content_type).to include('application/xml')
  end

  it 'is valid XML with urlset root element' do
    get '/sitemap.xml'

    doc = sitemap_xml
    expect(doc.errors).to be_empty
    expect(doc.root.name).to eq('urlset')
  end

  describe 'static pages' do
    it 'includes all static pages in both languages' do
      # The catalogue is listed in the languages it has courses in (#421).
      allow(Catalog).to receive(:create_keventer_json).and_return(
        Catalog.load_catalog_events([{ 'event_type_id' => 1, 'slug' => '1-scrum', 'lang' => 'es' },
                                     { 'event_type_id' => 68, 'slug' => '68-csm', 'lang' => 'en' }])
      )

      get '/sitemap.xml'

      expect(urls).to include('https://www.kleer.la/es/')
      expect(urls).to include('https://www.kleer.la/en/')
      expect(urls).to include('https://www.kleer.la/es/blog')
      expect(urls).to include('https://www.kleer.la/en/blog')
      expect(urls).to include('https://www.kleer.la/es/servicios')
      expect(urls).to include('https://www.kleer.la/en/services')
      expect(urls).to include('https://www.kleer.la/es/catalogo')
      expect(urls).to include('https://www.kleer.la/en/catalog')
      expect(urls).to include('https://www.kleer.la/es/agenda')
      expect(urls).to include('https://www.kleer.la/es/recursos')
      expect(urls).to include('https://www.kleer.la/en/resources')
      expect(urls).to include('https://www.kleer.la/es/somos')
      expect(urls).to include('https://www.kleer.la/en/about_us')
      expect(urls).to include('https://www.kleer.la/es/clientes')
      expect(urls).to include('https://www.kleer.la/en/clients')
      expect(urls).to include('https://www.kleer.la/es/podcasts')
      expect(urls).to include('https://www.kleer.la/es/novedades')
    end

    # Novedades and Podcasts have no English edition — the English URL answered
    # with the Spanish copy. A sitemap lists the pages worth indexing, and a
    # page that speaks the wrong language is not one of them.
    it 'leaves out the languages a section does not have' do
      get '/sitemap.xml'

      expect(urls).not_to include('https://www.kleer.la/en/news')
      expect(urls).not_to include('https://www.kleer.la/en/podcasts')
      expect(urls).not_to include('https://www.kleer.la/en/schedule')
    end

    # An article with no substantive_change_at used to raise inside the block
    # that builds them, and add_dynamic_urls catches: every article vanished
    # from the sitemap and only a log line said so.
    it 'lists an article that has no date' do
      allow(Article).to receive(:create_list_keventer).and_return(
        [Article.new('slug' => 'sin-fecha', 'lang' => 'es', 'published' => true)]
      )

      get '/sitemap.xml'

      expect(urls).to include('https://www.kleer.la/es/blog/sin-fecha')
    end

    it 'leaves out an article the admin marked noindex' do
      allow(Article).to receive(:create_list_keventer).and_return(
        [Article.new('slug' => 'visible', 'lang' => 'es', 'published' => true),
         Article.new('slug' => 'oculto', 'lang' => 'es', 'published' => true, 'noindex' => true)]
      )

      get '/sitemap.xml'

      expect(urls).to include('https://www.kleer.la/es/blog/visible')
      expect(urls).not_to include('https://www.kleer.la/es/blog/oculto')
    end

    it 'does not offer them as an alternate of the Spanish page either' do
      get '/sitemap.xml'

      doc = sitemap_xml
      links = doc.xpath('//xmlns:url[xmlns:loc[text()="https://www.kleer.la/es/novedades"]]/xhtml:link',
                        'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9',
                        'xhtml' => 'http://www.w3.org/1999/xhtml')

      expect(links.map { |l| l['hreflang'] }).to eq(['es'])
    end

    it 'includes hreflang alternates for static pages' do
      get '/sitemap.xml'

      doc = sitemap_xml
      xhtml_links = doc.xpath('//xmlns:url[xmlns:loc[contains(text(), "/es/blog")]]/xhtml:link',
                              'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9',
                              'xhtml' => 'http://www.w3.org/1999/xhtml')

      hreflangs = xhtml_links.map { |l| [l['hreflang'], l['href']] }
      expect(hreflangs).to include(['es', 'https://www.kleer.la/es/blog'])
      expect(hreflangs).to include(['en', 'https://www.kleer.la/en/blog'])
    end

    it 'sets priority 1.0 for homepage and 0.8 for other static pages' do
      get '/sitemap.xml'

      doc = sitemap_xml
      ns = { 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9' }

      home_priority = doc.xpath('//xmlns:url[xmlns:loc[contains(text(), "kleer.la/es/")]]/xmlns:priority', ns).first
      blog_priority = doc.xpath('//xmlns:url[xmlns:loc[contains(text(), "/es/blog")]]/xmlns:priority', ns).first

      expect(home_priority.text).to eq('1.0')
      expect(blog_priority.text).to eq('0.8')
    end
  end

  describe 'blog articles' do
    let(:articles) do
      [
        Article.new({
                      'id' => 1, 'title' => 'Test Article', 'slug' => 'test-article',
                      'lang' => 'es', 'published' => true, 'description' => 'desc',
                      'substantive_change_at' => '2025-03-15T10:00:00Z'
                    }),
        Article.new({
                      'id' => 2, 'title' => 'Unpublished', 'slug' => 'unpublished',
                      'lang' => 'es', 'published' => false, 'description' => 'desc'
                    })
      ]
    end

    before do
      allow(Article).to receive(:create_list_keventer).and_return(articles)
    end

    it 'includes published articles' do
      get '/sitemap.xml'

      expect(urls).to include('https://www.kleer.la/es/blog/test-article')
    end

    it 'excludes unpublished articles' do
      get '/sitemap.xml'

      expect(urls).not_to include('https://www.kleer.la/es/blog/unpublished')
    end

    it 'includes lastmod from substantive_change_at' do
      get '/sitemap.xml'

      doc = sitemap_xml
      ns = { 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9' }
      lastmod = doc.xpath('//xmlns:url[xmlns:loc[contains(text(), "test-article")]]/xmlns:lastmod', ns).first

      expect(lastmod.text).to eq('2025-03-15')
    end
  end

  describe 'service areas and services' do
    let(:service_areas) do
      area = ServiceAreaV3.new
      area.load_from_json({
                            'id' => 1, 'slug' => 'coaching', 'lang' => 'es', 'name' => 'Coaching',
                            'is_training_program' => false,
                            'services' => [
                              { 'id' => 10, 'slug' => 'agile-coaching', 'name' => 'Agile Coaching' }
                            ]
                          })
      [area]
    end

    before do
      allow(ServiceAreaV3).to receive(:try_create_list_keventer).and_return(service_areas)
    end

    it 'includes service areas and their services' do
      get '/sitemap.xml'

      expect(urls).to include('https://www.kleer.la/es/servicios/coaching')
      expect(urls).to include('https://www.kleer.la/es/servicios/coaching/agile-coaching')
    end

    it 'excludes training programs from services section' do
      program = ServiceAreaV3.new
      program.load_from_json({
                               'id' => 2, 'slug' => 'program-x', 'lang' => 'es', 'name' => 'Program X',
                               'is_training_program' => true, 'services' => []
                             })
      allow(ServiceAreaV3).to receive(:try_create_list_keventer).and_return([program])

      get '/sitemap.xml'

      expect(urls).not_to include('https://www.kleer.la/es/servicios/program-x')
    end
  end

  describe 'catalog courses' do
    let(:event_type) do
      EventType.new({
                      'id' => 1, 'slug' => 'scrum-master', 'name' => 'Scrum Master',
                      'lang' => 'es', 'deleted' => false, 'noindex' => false,
                      'elevator_pitch' => 'Learn Scrum'
                    })
    end

    let(:event) do
      e = Event.new(event_type)
      e
    end

    before do
      allow(Catalog).to receive(:create_keventer_json).and_return([event])
    end

    it 'includes catalog courses' do
      get '/sitemap.xml'

      expect(urls).to include('https://www.kleer.la/es/cursos/scrum-master')
    end

    it 'excludes courses that redirect somewhere else' do
      # A course with an external site answers 301 to it: listing the URL sends
      # crawlers to a redirect and tells them our sitemap is unreliable.
      elsewhere = EventType.new({
                                  'id' => 4, 'slug' => 'agilidad-primeros-pasos', 'name' => 'Primeros pasos',
                                  'lang' => 'es', 'deleted' => false, 'noindex' => false,
                                  'external_site_url' => 'https://academia.kleer.la/p/agilidad-primeros-pasos'
                                })
      allow(Catalog).to receive(:create_keventer_json).and_return([Event.new(elsewhere)])

      get '/sitemap.xml'

      expect(urls).not_to include('https://www.kleer.la/es/cursos/agilidad-primeros-pasos')
    end

    it 'excludes deleted courses' do
      deleted_et = EventType.new({
                                   'id' => 2, 'slug' => 'old-course', 'name' => 'Old',
                                   'lang' => 'es', 'deleted' => true, 'noindex' => false
                                 })
      deleted_event = Event.new(deleted_et)
      allow(Catalog).to receive(:create_keventer_json).and_return([deleted_event])

      get '/sitemap.xml'

      expect(urls).not_to include('https://www.kleer.la/es/cursos/old-course')
    end

    it 'excludes noindex courses' do
      noindex_et = EventType.new({
                                   'id' => 3, 'slug' => 'hidden-course', 'name' => 'Hidden',
                                   'lang' => 'es', 'deleted' => false, 'noindex' => true
                                 })
      noindex_event = Event.new(noindex_et)
      allow(Catalog).to receive(:create_keventer_json).and_return([noindex_event])

      get '/sitemap.xml'

      expect(urls).not_to include('https://www.kleer.la/es/cursos/hidden-course')
    end

    # Through the catalog JSON as Keventer sends it: flat, one hash per course
    # (#440). The noindex field arrived from kleer-la/eventer only now.
    it 'excludes a noindex course read from the catalog JSON' do
      courses = [{ 'event_type_id' => 414, 'slug' => '414-agile-products-with-scrum', 'name' => 'Agile Products',
                   'lang' => 'en', 'noindex' => true, 'external_site_url' => '' },
                 { 'event_type_id' => 68, 'slug' => '68-csm', 'name' => 'CSM', 'lang' => 'en', 'noindex' => false }]
      allow(Catalog).to receive(:create_keventer_json).and_return(Catalog.load_catalog_events(courses))

      get '/sitemap.xml'

      expect(urls).not_to include('https://www.kleer.la/en/courses/414-agile-products-with-scrum')
      expect(urls).to include('https://www.kleer.la/en/courses/68-csm')
    end

    it 'deduplicates courses by lang and slug' do
      dup_event = Event.new(event_type)
      allow(Catalog).to receive(:create_keventer_json).and_return([event, dup_event])

      get '/sitemap.xml'

      course_urls = urls.select { |u| u.include?('cursos/scrum-master') }
      expect(course_urls.length).to eq(1)
    end
  end

  describe 'resources' do
    before do
      allow(Resource).to receive(:create_list_keventer).and_call_original
      Resource.create_list_null([
                                  {
                                    'id' => 1, 'slug' => 'retromat', 'format' => 'download',
                                    'title_es' => 'Retromat', 'title_en' => '',
                                    'description_es' => 'Una herramienta', 'description_en' => ''
                                  }
                                ])
    end

    after do
      Resource.instance_variable_set(:@next_null, false)
    end

    it 'includes resources with non-empty titles' do
      get '/sitemap.xml'

      expect(urls).to include('https://www.kleer.la/es/recursos/retromat')
    end
  end

  # A resource may have an English slug of its own (kleer-la/eventer#227): the
  # English URLs use it, the Spanish ones the Spanish slug (#435).
  describe 'resources with an English slug' do
    before do
      allow(Resource).to receive(:create_list_keventer).and_call_original
      Resource.create_list_null([
                                  { 'id' => 3, 'slug' => 'conceptos-de-ia', 'slug_en' => 'ai-concepts',
                                    'format' => 'concepts', 'title_es' => 'Conceptos de IA',
                                    'title_en' => 'AI concepts',
                                    'concepts' => [{ 'slug' => 'agent', 'lang' => 'en' }] },
                                  { 'id' => 4, 'slug' => 'kartas', 'format' => 'card',
                                    'title_es' => 'Kartas', 'title_en' => 'Kards' }
                                ])
    end

    after do
      Resource.instance_variable_set(:@next_null, false)
    end

    it 'lists each language under its own slug, the Spanish one when there is no English one' do
      get '/sitemap.xml'

      expect(urls).to include('https://www.kleer.la/es/recursos/conceptos-de-ia',
                              'https://www.kleer.la/en/resources/ai-concepts',
                              'https://www.kleer.la/en/resources/ai-concepts/agent',
                              'https://www.kleer.la/en/resources/kartas')
      expect(urls).not_to include('https://www.kleer.la/en/resources/conceptos-de-ia')
    end
  end

  # A concepts resource has a page per concept, and each one is worth indexing
  # on its own: listed under the resource, in the language it was written in.
  describe 'concepts resources' do
    before do
      allow(Resource).to receive(:create_list_keventer).and_call_original
      Resource.create_list_null([
                                  {
                                    'id' => 2, 'slug' => 'conceptos-de-ia', 'format' => 'concepts',
                                    'title_es' => 'Conceptos de IA', 'title_en' => 'AI concepts',
                                    'updated_at' => '2026-10-01T12:00:00.000Z',
                                    'concepts' => [
                                      { 'slug' => 'token', 'lang' => 'es', 'updated_at' => '2026-09-15T10:00:00Z' },
                                      { 'slug' => 'agente', 'lang' => 'es', 'updated_at' => '2026-09-20T10:00:00Z' },
                                      { 'slug' => 'agent', 'lang' => 'en', 'updated_at' => '2026-09-21T10:00:00Z' }
                                    ]
                                  }
                                ])
    end

    after do
      Resource.instance_variable_set(:@next_null, false)
    end

    def url_node(loc)
      doc = sitemap_xml
      doc.remove_namespaces!
      doc.xpath('//url').find { |u| u.at_xpath('loc').text == loc }
    end

    it 'lists a URL per concept, in its own language' do
      get '/sitemap.xml'

      expect(urls).to include('https://www.kleer.la/es/recursos/conceptos-de-ia/token',
                              'https://www.kleer.la/es/recursos/conceptos-de-ia/agente',
                              'https://www.kleer.la/en/resources/conceptos-de-ia/agent')
      expect(urls).not_to include('https://www.kleer.la/en/resources/conceptos-de-ia/token',
                                  'https://www.kleer.la/es/recursos/conceptos-de-ia/agent')
    end

    it 'dates each concept and gives it the frequency and priority of its resource' do
      get '/sitemap.xml'

      node = url_node('https://www.kleer.la/es/recursos/conceptos-de-ia/token')
      expect(node.at_xpath('lastmod').text).to eq('2026-09-15')
      expect(node.at_xpath('changefreq').text).to eq('monthly')
      expect(node.at_xpath('priority').text).to eq('0.6')
      expect(node.xpath('link').map { |l| [l['hreflang'], l['href']] })
        .to eq([['es', 'https://www.kleer.la/es/recursos/conceptos-de-ia/token']])
    end
  end

  describe 'training programs' do
    let(:program) do
      p = ServiceAreaV3.new
      p.load_from_json({
                         'id' => 5, 'slug' => 'agile-program', 'lang' => 'es', 'name' => 'Agile Program',
                         'is_training_program' => true, 'services' => []
                       })
      p
    end

    before do
      allow(ServiceAreaV3).to receive(:try_create_list_keventer).with(no_args).and_return([])
      allow(ServiceAreaV3).to receive(:try_create_list_keventer).with(programs: true).and_return([program])
    end

    it 'includes training programs' do
      get '/sitemap.xml'

      expect(urls).to include('https://www.kleer.la/es/formacion/agile-program')
    end
  end

  describe 'error handling' do
    it 'returns valid sitemap when articles API fails' do
      allow(Article).to receive(:create_list_keventer).and_raise(StandardError.new('API down'))

      get '/sitemap.xml'

      expect(last_response.status).to eq(200)
      expect(urls).to include('https://www.kleer.la/es/')
    end

    it 'returns valid sitemap when catalog API fails' do
      allow(Catalog).to receive(:create_keventer_json).and_raise(StandardError.new('API down'))

      get '/sitemap.xml'

      expect(last_response.status).to eq(200)
      expect(urls).to include('https://www.kleer.la/es/')
    end
  end
end
