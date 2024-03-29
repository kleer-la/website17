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
end
