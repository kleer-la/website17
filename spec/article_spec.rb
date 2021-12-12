require './lib/articles'
require 'spec_helper'

describe Article do
  it 'title' do
    doc = { 'title' => 'Lorem Ipsum' }
    article = Article.new(doc)
    expect(article.title).to eq 'Lorem Ipsum'
  end
end
