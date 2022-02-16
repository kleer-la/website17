require './lib/json_api'
require './lib/articles'

get '/blog/' do
  redirect '/blog', 301 # permanent redirect
end

get '/blog-preview/:slug' do |slug|
  meta_tags! noindex: true, nofollow: true

  blog_one Article.create_one_keventer(slug)
end

get '/blog-preview' do
  meta_tags! noindex: true, nofollow: true

  @where = 'Blog Preview'

  blog_list Article.create_list_keventer(false)
end

get '/blog' do
  @where = 'Blog'

  blog_list Article.create_list_keventer(true)
end

get '/blog/:slug' do |slug|
  blog_one Article.create_one_keventer(slug)
end

def blog_one(article)
  @article = article
  @page_title = @article.tabtitle
  @meta_description = @article.description

  erb :blog_preview_one
rescue StandardError => e
  puts e
  status 404
end

def blog_list(articles)
  meta_tags! title: 'Blog - Artículos sobre agilidad organizacional'
  meta_tags! description: 'Contenido relevante en español: Scrum, Mejora continua, Lean, Product Discovery, Agile Coaching, Liderazgo, Facilitación, Comunicación Colaborativa, Kanban.'
  @articles = articles

  @show_abstract = true
  erb :blog_preview
rescue StandardError => e
  puts e
  status 404
end
