require './lib/json_api'
require './lib/articles'

# get '/blog' do
#   redirect '/blog/', 301 # permanent redirect
# end

get '/blog-preview/:slug' do |slug|
  @article = Article.createOneKeventer(slug)

  # @meta_keywords
  @page_title = @article.tabtitle
  @meta_description = @article.description

  erb :blog_preview_one
rescue StandardError => e
  puts e
  status 404
end

get '/blog-preview' do
  @articles = Article.createListKeventer(false)

  # @meta_keywords
  # @page_title = @article.tabtitle
  # @meta_description = @article.description

  @preview = 'Preview'
  erb :blog_preview
rescue StandardError => e
  puts e
  status 404
end

get '/blog' do
  @articles = Article.createListKeventer(true)

  # @meta_keywords
  # @page_title = @article.tabtitle
  # @meta_description = @article.description

  erb :blog_preview
rescue StandardError => e
  puts e
  status 404
end
