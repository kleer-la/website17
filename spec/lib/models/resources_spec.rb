require './lib/models/resources'
require 'spec_helper'

describe Resource do
  describe '#initialize' do
    it 'basic attributes in Spanish' do
      doc = {
        'id' => 1,
        'slug' => 'test-resource',
        'format' => 'pdf',
        'title_es' => 'Título de Prueba',
        'description_es' => 'Descripción de prueba',
        'authors' => [{ 'name' => 'John Doe', 'landing' => 'https://twitter.com/jdoe' }],
        'translators' => [],
        'illustrators' => []
      }
      resource = Resource.new(doc, :es)

      expect(resource.id).to eq 1
      expect(resource.slug).to eq 'test-resource'
      expect(resource.format).to eq 'pdf'
      expect(resource.title).to eq 'Título de Prueba'
      expect(resource.description).to eq 'Descripción de prueba'
      expect(resource.lang).to eq :es
    end

    it 'basic attributes in English' do
      doc = {
        'id' => 1,
        'slug' => 'test-resource',
        'format' => 'pdf',
        'title_en' => 'Test Title',
        'description_en' => 'Test description',
        'authors' => [{ 'name' => 'John Doe' }],
        'translators' => [],
        'illustrators' => []
      }
      resource = Resource.new(doc, :en)

      expect(resource.title).to eq 'Test Title'
      expect(resource.description).to eq 'Test description'
      expect(resource.lang).to eq :en
    end
  end

  describe '#authors and authors_list' do
    it 'handles authors with landing pages' do
      doc = {
        'authors' => [
          { 'name' => 'John Doe', 'landing' => 'http://example.com/john' },
          { 'name' => 'Jane Smith', 'landing' => 'http://example.com/jane' }
        ],
        'translators' => [],
        'illustrators' => []
      }
      resource = Resource.new(doc, 'es')

      expect(resource.authors).to include('<a href="http://example.com/john">John Doe</a>')
      expect(resource.authors).to include('<a href="http://example.com/jane">Jane Smith</a>')
      expect(resource.authors_list).to eq(['John Doe', 'Jane Smith'])
    end

    it 'handles authors without landing pages' do
      doc = {
        'authors' => [
          { 'name' => 'John Doe', 'landing' => '' },
          { 'name' => 'Jane Smith', 'landing' => nil }
        ],
        'translators' => [],
        'illustrators' => []
      }
      resource = Resource.new(doc, 'es')

      expect(resource.authors).to eq('John Doe, Jane Smith')
      expect(resource.authors_list).to eq(['John Doe', 'Jane Smith'])
    end
  end

  describe '#share links' do
    it 'generates correct share URLs' do
      doc = {
        'slug' => 'test-resource',
        'share_text_es' => 'Check this out!',
        'tags_es' => 'agile,scrum',
        'authors' => [],
        'translators' => [],
        'illustrators' => []
      }
      resource = Resource.new(doc, :es)

      expect(resource.fb_share).to include('quote=Check+this+out')
      expect(resource.tw_share).to include('text=Check+this+out')
      expect(resource.li_share).to include('hashtags=agile%2Cscrum')
    end

    it 'uses custom share link when provided' do
      doc = {
        'slug' => 'test-resource',
        'share_link_es' => 'http://custom.com/share',
        'authors' => [],
        'translators' => [],
        'illustrators' => []
      }
      resource = Resource.new(doc, :es)

      expect(resource.fb_share).to include('custom.com')
      expect(resource.tw_share).to include('custom.com')
      expect(resource.li_share).to include('custom.com')
    end
  end

  describe '.load_list' do
    it 'loads resources for both languages when available' do
      doc = [{
        'id' => 1,
        'title_es' => 'Título Español',
        'title_en' => 'English Title',
        'authors' => [],
        'translators' => [],
        'illustrators' => []
      }]

      resources = Resource.load_list(doc)
      expect(resources.count).to eq 2
      expect(resources.map(&:lang)).to contain_exactly(:es, :en)
    end

    it 'skips empty language versions' do
      doc = [{
        'id' => 1,
        'title_es' => 'Título Español',
        'title_en' => '',
        'authors' => [],
        'translators' => [],
        'illustrators' => []
      }]

      resources = Resource.load_list(doc)
      expect(resources.count).to eq 1
      expect(resources.first.lang).to eq :es
    end
  end

  describe '.create_one_keventer' do
    it 'raises ResourceNotFoundError when resource not found' do
      allow(JsonAPI).to receive(:new).and_raise(ResourceNotFoundError.new('non-existent'))

      expect do
        Resource.create_one_keventer('non-existent')
      end.to raise_error(ResourceNotFoundError, "Resource with slug 'non-existent' not found")
    end
  end

  describe '.create_one_null' do
    it 'creates test resource and enables null testing mode' do
      test_resource = {
        'id' => 1,
        'slug' => 'test',
        'title_es' => 'Test',
        'lang' => :es,
        'authors' => [],
        'translators' => [],
        'illustrators' => []
      }

      Resource.create_one_null(test_resource, 'es', next_null: true)
      resource = Resource.create_one_keventer('test')

      expect(resource.id).to eq 1
      expect(resource.title).to eq 'Test'
    end
  end

  describe '#also_download' do
    it 'excludes recommended resources with empty title' do
      resource = Resource.new({ 'id' => 1, 'title_es' => 'Main Resource', 'authors' => [], 'translators' => [], 'illustrators' => [], 'downloadable' => true,
      'recommended' => [
        {
        "id"=> 13,
        "slug"=> "dor-kards",
        "type"=> "resource",
        "title"=> "DoR Kards",
        "subtitle"=> "A card game where the goal is to brainstorm and reach consensus as a team on the criteria to be included in its Definition of Ready (DoR).",
        "cover"=> "/img/recursos/DoR-Kards-en.png",
        "downloadable"=> true,
        "relevance_order"=> 250,
        "level"=> "advanced"
        },
        {
        "id"=> 13,
        "slug"=> "dod-kards",
        "type"=> "resource",
        "title"=> "",
        "subtitle"=> "",
        "cover"=> "",
        "downloadable"=> true,
        "relevance_order"=> 250,
        "level"=> "advanced"
        }
      ]
      }, 'en')

      result = resource.also_download(2)
      expect(result.count).to eq(1)
      expect(result[0].title).to eq('DoR Kards')
    end
  end
end
