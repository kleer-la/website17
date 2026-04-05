require 'spec_helper'
require './app'
require 'json'

describe JsonLdHelper do
  include JsonLdHelper

  # Stub session for website_json_ld
  def session
    { locale: 'es' }
  end

  describe '#json_ld_tag' do
    it 'wraps data in a script tag with application/ld+json type' do
      data = { '@type' => 'Organization', 'name' => 'Test' }
      result = json_ld_tag(data)

      expect(result).to include('<script type="application/ld+json">')
      expect(result).to include('</script>')
      expect(JSON.parse(result.match(/>(.+)</m)[1])).to eq(data)
    end
  end

  describe '#organization_json_ld' do
    subject { organization_json_ld }

    it 'returns Organization schema' do
      expect(subject['@context']).to eq('https://schema.org')
      expect(subject['@type']).to eq('Organization')
      expect(subject['name']).to eq('Kleer')
      expect(subject['url']).to eq('https://www.kleer.la')
      expect(subject['logo']).to be_a(String)
    end
  end

  describe '#website_json_ld' do
    subject { website_json_ld }

    it 'returns WebSite schema with current language' do
      expect(subject['@type']).to eq('WebSite')
      expect(subject['name']).to eq('Kleer')
      expect(subject['inLanguage']).to include('es')
    end
  end

  describe '#article_json_ld' do
    let(:article) do
      Article.new({
        'id' => 1, 'title' => 'Test Article', 'slug' => 'test-article',
        'lang' => 'es', 'published' => true, 'description' => 'A test article',
        'cover' => 'https://cdn.kleer.la/test.jpg',
        'created_at' => '2025-01-15', 'substantive_change_at' => '2025-03-20',
        'trainers' => [{ 'name' => 'Jane Doe', 'gravatar' => '' }]
      })
    end

    subject { article_json_ld(article) }

    it 'returns Article schema with correct fields' do
      expect(subject['@type']).to eq('Article')
      expect(subject['headline']).to eq('Test Article')
      expect(subject['description']).to eq('A test article')
      expect(subject['url']).to eq('https://www.kleer.la/es/blog/test-article')
      expect(subject['inLanguage']).to eq('es')
      expect(subject['image']).to include('test.jpg')
      expect(subject['datePublished']).to eq('2025-01-15')
      expect(subject['dateModified']).to eq('2025-03-20')
    end

    it 'includes trainer as author' do
      expect(subject['author']).to be_an(Array)
      expect(subject['author'].first['name']).to eq('Jane Doe')
    end

    it 'falls back to Organization author when no trainers' do
      article_no_trainers = Article.new({
        'id' => 2, 'title' => 'No Author', 'slug' => 'no-author',
        'lang' => 'es', 'published' => true, 'description' => 'desc'
      })

      result = article_json_ld(article_no_trainers)

      expect(result['author']['@type']).to eq('Organization')
      expect(result['author']['name']).to eq('Kleer')
    end

    it 'includes publisher' do
      expect(subject['publisher']['@type']).to eq('Organization')
      expect(subject['publisher']['name']).to eq('Kleer')
    end
  end

  describe '#service_json_ld' do
    let(:service) do
      ServiceV3.new({
        'id' => 1, 'name' => 'Agile Coaching', 'slug' => 'agile-coaching',
        'subtitle' => 'Transform your team', 'seo_description' => 'Professional coaching'
      })
    end

    let(:service_area) do
      area = ServiceAreaV3.new
      area.name = 'Coaching'
      area
    end

    subject { service_json_ld(service, service_area) }

    it 'returns Service schema' do
      expect(subject['@type']).to eq('Service')
      expect(subject['name']).to eq('Agile Coaching')
      expect(subject['description']).to eq('Professional coaching')
      expect(subject['category']).to eq('Coaching')
      expect(subject['provider']['name']).to eq('Kleer')
    end

    it 'falls back to subtitle when seo_description is nil' do
      service_no_seo = ServiceV3.new({
        'id' => 2, 'name' => 'Test', 'slug' => 'test',
        'subtitle' => 'The subtitle', 'seo_description' => nil
      })

      result = service_json_ld(service_no_seo, service_area)

      expect(result['description']).to eq('The subtitle')
    end
  end

  describe '#course_json_ld' do
    let(:event_type) do
      EventType.new({
        'id' => 1, 'slug' => 'scrum-master', 'name' => 'Certified Scrum Master',
        'lang' => 'es', 'elevator_pitch' => 'Learn Scrum fundamentals',
        'cover' => 'https://cdn.kleer.la/scrum.jpg'
      })
    end

    subject { course_json_ld(event_type) }

    it 'returns Course schema' do
      expect(subject['@type']).to eq('Course')
      expect(subject['name']).to eq('Certified Scrum Master')
      expect(subject['description']).to eq('Learn Scrum fundamentals')
      expect(subject['inLanguage']).to eq('es')
      expect(subject['provider']['name']).to eq('Kleer')
    end

    it 'includes cover image' do
      expect(subject['image']).to include('scrum.jpg')
    end
  end

  describe '#resource_json_ld' do
    let(:resource) do
      Resource.new({
        'id' => 1, 'slug' => 'retromat', 'format' => 'download',
        'title_es' => 'Retromat', 'description_es' => 'Herramienta de retrospectivas',
        'seo_description_es' => 'Planes de retrospectivas',
        'cover_es' => 'https://cdn.kleer.la/retromat.jpg',
        'authors' => [{ 'name' => 'John Doe', 'gravatar' => '' }]
      }, 'es')
    end

    subject { resource_json_ld(resource) }

    it 'returns CreativeWork schema' do
      expect(subject['@type']).to eq('CreativeWork')
      expect(subject['name']).to eq('Retromat')
      expect(subject['description']).to eq('Planes de retrospectivas')
      expect(subject['url']).to eq('https://www.kleer.la/es/recursos/retromat')
      expect(subject['inLanguage']).to eq('es')
    end

    it 'includes authors' do
      expect(subject['author']).to be_an(Array)
      expect(subject['author'].first['name']).to eq('John Doe')
    end
  end
end
