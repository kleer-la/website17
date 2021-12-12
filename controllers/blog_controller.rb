require './lib/json_api'
require './lib/articles'

get '/blog' do
  redirect '/blog/', 301 # permanent redirect
end

get '/blog-preview/:slug' do |slug|
  uri = "http://keventer-test.herokuapp.com/articles/#{slug}.json"
  api_resp = JsonAPI.new(uri)
  if !api_resp.ok?
    status 404
  else
    @article = Article.new(api_resp.doc)

    # @meta_keywords
    @page_title = @article.tabtitle
    @meta_description = @article.description

    erb :blog_preview, layout: :layout_2017
  end
end
