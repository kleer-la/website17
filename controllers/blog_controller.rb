require './lib/json_api'
require './lib/articles'

get '/blog/' do
  redirect '/blog', 301 # permanent redirect
end

get '/blog-preview/:slug' do |slug|
  meta_tags! noindex: true, nofollow: true

  begin
    blog_one Article.create_one_keventer(slug)
  rescue StandardError => e
    puts e
    status 404
  end
end

get '/blog-preview' do
  meta_tags! noindex: true, nofollow: true

  @where = 'Blog Preview'

  blog_list Article.create_list_keventer(false)
end

get '/blog2022' do
  session[:version] = 2022
  @where = 'Blog'
  blog_list Article.create_list_keventer(true)
end
get '/blog' do
  @where = 'Blog'
  
  blog_list Article.create_list_keventer(true)
end

get '/blog/:slug' do |slug|
  @where = 'Blog'
  blog_one Article.create_one_keventer(slug)
rescue StandardError => e
  puts e
  status 404
end

def blog_one(article)
  @article = article
  meta_tags! title: @article.tabtitle,
             description: @article.description

  return erb :'blog/article', layout: :'layout/layout2022'  if session[:version] == 2022

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
  return erb :'blog/index', layout: :'layout/layout2022' if session[:version] == 2022

  erb :blog_preview

rescue StandardError => e
  puts e
  status 404
end
