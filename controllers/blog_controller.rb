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
  @articles = Article.create_list_keventer(false)

  # @meta_keywords
  # @page_title = @article.tabtitle
  # @meta_description = @article.description

  @show_abstract = true
  @where = 'Blog Preview'
  erb :blog_preview
rescue StandardError => e
  puts e
  status 404
end

get '/blog' do
  @articles = Article.create_list_keventer(true)

  @where = 'Blog'
  # @meta_keywords
  # @page_title = @article.tabtitle
  # @meta_description = @article.description

  @show_abstract = false
  erb :blog_preview
rescue StandardError => e
  puts e
  status 404
end
get '/blog/:slug' do |slug|
  @article = Article.createOneKeventer(slug)

  # @meta_keywords
  @page_title = @article.tabtitle
  @meta_description = @article.description

  erb :blog_preview_one
rescue StandardError => e
  puts e
  status 404
end
