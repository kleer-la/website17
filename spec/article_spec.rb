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
    'trainers' => [{'name' => 'Luke'}] }
    article = Article.new(doc)
    expect(article.trainers[0]).to eq 'Luke'
  end
  it 'Load list' do
    doc = [{ 'title' => 'Lorem Ipsum', 
    'trainers' => [{'name' => 'Luke'}] }]
    articles = Article.load_list(doc)
    expect(articles[0].title).to eq 'Lorem Ipsum'
  end
end
