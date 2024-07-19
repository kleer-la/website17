require './lib/articles'
require 'spec_helper'

describe Article do
  it 'title' do
    doc = { 'title' => 'Lorem Ipsum' }
    article = Article.new(doc)
    expect(article.title).to eq 'Lorem Ipsum'
  end
  it 'trainers' do
    doc = { 'title' => 'Lorem Ipsum',
            'trainers' => [{ 'name' => 'Luke' }] }
    article = Article.new(doc)
    expect(article.trainers[0]).to eq 'Luke'
  end
  it 'Load list full (publish and unpublish)' do
    doc = [
      { 'title' => 'Lorem Ipsum',
        'trainers' => [{ 'name' => 'Luke' }] },
      { 'title' => 'Dolor sit',
        'published' => true,
        'trainers' => [{ 'name' => 'Luke' }] }
    ]
    articles = Article.load_list(doc)
    expect(articles[0].title).to eq 'Lorem Ipsum'
    expect(articles.count).to eq 2
  end
  it 'Load list - only published' do
    doc = [
      { 'title' => 'Lorem Ipsum',
        'trainers' => [{ 'name' => 'Luke' }] },
      { 'title' => 'Dolor sit',
        'published' => true,
        'trainers' => [{ 'name' => 'Luke' }] }
    ]
    articles = Article.load_list(doc, only_published: true)
    expect(articles[0].title).to eq 'Dolor sit'
    expect(articles.count).to eq 1
  end
  context 'description' do
    it 'w/o ' do
      doc = { 'title' => 'Lorem Ipsum' }
      article = Article.new(doc)
      expect(article.description).to eq ''
    end
    it 'with' do
      doc = { 'title' => 'Lorem Ipsum',
              'description' => 'some text' }
      article = Article.new(doc)
      expect(article.description).to eq 'some text'
    end
  end

  describe '#init_recommended' do
    let(:article) { Article.new({}) }

    context 'with valid recommendation types' do
      let(:valid_doc) do
        {
          'recommended' => [
            { 'type' => 'article', 'id' => 1 },
            { 'type' => 'event_type', 'id' => 2 },
            { 'type' => 'service', 'id' => 3 }
          ]
        }
      end

      it 'initializes recommended items correctly' do
        article.init_recommended(valid_doc)
        expect(article.recommended.size).to eq(3)
        expect(article.recommended[0]).to be_a(RecommendedArticle)
        expect(article.recommended[1]).to be_a(RecommendedEventType)
        expect(article.recommended[2]).to be_a(RecommendedService)
      end
    end

    context 'with unknown recommendation types' do
      let(:doc_with_unknown) do
        {
          'recommended' => [
            { 'type' => 'article', 'id' => 1 },
            { 'type' => 'unknown', 'id' => 2 },
            { 'type' => 'service', 'id' => 3 }
          ]
        }
      end

      it 'ignores unknown types and initializes valid ones' do
        expect { article.init_recommended(doc_with_unknown) }.to output(/Unknown recommendation type: unknown/).to_stdout
        expect(article.recommended.size).to eq(2)
        expect(article.recommended[0]).to be_a(RecommendedArticle)
        expect(article.recommended[1]).to be_a(RecommendedService)
      end
    end

    context 'with empty recommendations' do
      let(:empty_doc) { { 'recommended' => [] } }

      it 'initializes an empty array' do
        article.init_recommended(empty_doc)
        expect(article.recommended).to be_empty
      end
    end

    context 'with nil recommendations' do
      let(:nil_doc) { { 'recommended' => nil } }

      it 'initializes an empty array' do
        article.init_recommended(nil_doc)
        expect(article.recommended).to be_empty
      end
    end

    context 'with missing recommendations key' do
      let(:missing_key_doc) { {} }

      it 'initializes an empty array' do
        article.init_recommended(missing_key_doc)
        expect(article.recommended).to be_empty
      end
    end
  end
  
end
