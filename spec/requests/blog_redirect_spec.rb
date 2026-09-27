require 'spec_helper'
require './app'

# Marketing merges articles that compete for the same search and retires the
# ones nobody reads towards their area page (kleer-la/kleer-marketing#6, #4).
# The old URL keeps its traffic with a 301 to wherever Keventer says the article
# went — even after it was unpublished to leave the blog list. Until now the
# only way was a PERMANENT_REDIRECT entry and a deploy (kleer-la/website17#429).
describe 'an article with a redirect_url' do
  def app
    Sinatra::Application.new
  end

  def article(attrs)
    Article.new({ 'id' => 1, 'title' => 'Viejo', 'slug' => 'viejo', 'lang' => 'es', 'published' => true,
                  'description' => 'desc', 'body' => 'cuerpo' }.merge(attrs))
  end

  before do
    allow(Page).to receive(:load_from_keventer).and_return(Page.new)
    allow(Article).to receive(:create_list_keventer).and_return([])
  end

  it 'answers 301 to a path on the site' do
    allow(Article).to receive(:create_one_keventer).with('viejo')
                                                   .and_return(article('redirect_url' => '/es/blog/nuevo'))

    get '/es/blog/viejo'

    expect(last_response.status).to eq(301)
    expect(last_response.location).to end_with('/es/blog/nuevo')
  end

  it 'answers 301 to an absolute URL' do
    allow(Article).to receive(:create_one_keventer)
      .and_return(article('redirect_url' => 'https://www.kleer.la/es/servicios/agilidad'))

    get '/es/blog/viejo'

    expect(last_response.status).to eq(301)
    expect(last_response.location).to eq('https://www.kleer.la/es/servicios/agilidad')
  end

  # Unpublishing takes the article out of the listing; the redirect must survive it.
  it 'redirects even when the article is unpublished' do
    allow(Article).to receive(:create_one_keventer)
      .and_return(article('published' => false, 'redirect_url' => '/es/servicios/agilidad'))

    get '/es/blog/viejo'

    expect(last_response.status).to eq(301)
    expect(last_response.location).to end_with('/es/servicios/agilidad')
  end

  it 'still answers 404 for an unpublished article without one' do
    allow(Article).to receive(:create_one_keventer).and_return(article('published' => false))

    get '/es/blog/viejo'

    expect(last_response.status).to eq(404)
  end

  it 'treats an empty redirect_url as none' do
    allow(Article).to receive(:create_one_keventer).and_return(article('redirect_url' => '  '))

    get '/es/blog/viejo'

    expect(last_response.status).to eq(200)
  end
end
