require './lib/json_api'
require './lib/articles'

get '/blog' do
  redirect '/blog/', 301 # permanent redirect
end

get '/blog-preview/:slug' do |slug|
  begin
    @article = Article.createOneKeventer(slug)
    p @article

    # @meta_keywords
    @page_title = @article.tabtitle
    @meta_description = @article.description

    erb :blog_preview_one, layout: :layout_2017
  rescue => e
    print_exception(e, false)
    status 404
  end
end

get '/blog-preview' do 
  begin
    @articles = Article.createListKeventer

    # @meta_keywords
    # @page_title = @article.tabtitle
    # @meta_description = @article.description

    erb :blog_preview, layout: :layout_2017
  rescue
    status 404
  end
end
