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
    sitemap_xml.remove_namespaces!
    sitemap_xml.xpath('//url/loc').map(&:text)
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
      expect(urls).to include('https://www.kleer.la/en/schedule')
      expect(urls).to include('https://www.kleer.la/es/recursos')
      expect(urls).to include('https://www.kleer.la/en/resources')
      expect(urls).to include('https://www.kleer.la/es/somos')
      expect(urls).to include('https://www.kleer.la/en/about_us')
      expect(urls).to include('https://www.kleer.la/es/clientes')
      expect(urls).to include('https://www.kleer.la/en/clients')
      expect(urls).to include('https://www.kleer.la/es/podcasts')
      expect(urls).to include('https://www.kleer.la/en/podcasts')
      expect(urls).to include('https://www.kleer.la/es/novedades')
      expect(urls).to include('https://www.kleer.la/en/news')
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
