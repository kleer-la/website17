require './lib/json_api'
require './lib/articles'

get '/blog/' do
  redirect '/blog', 301 # permanent redirect
end

get '/blog-preview/:slug' do |slug|
  @meta_tags.set! noindex: true, nofollow: true
  @where = 'Blog-Preview'

  begin
    blog_one Article.create_one_keventer(slug)
  rescue StandardError => e
    puts e.message + ' - ' + e.backtrace.grep_v(%r{/gems/}).join('\n')
    status 404
  end
end

get '/blog-preview' do
  @meta_tags.set! noindex: true, nofollow: true

  @where = 'Blog-Preview'

  blog_list Article.create_list_keventer(false)
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
  @meta_tags.set! title: @article.tabtitle,
             description: @article.description

  erb :'blog/article', layout: :'layout/layout2022'

rescue StandardError => e
  puts e
  status 404
end

def blog_list(articles)
  @meta_tags.set! title: t('meta_tag.blog.title'),
                  description: t('meta_tag.blog.description'),
                  canonical: "#{session[:locale]}#{t('meta_tag.blog.canonical')}"

  @articles = articles
  @show_abstract = true
  erb :'blog/index', layout: :'layout/layout2022'

rescue StandardError => e
  puts e
  status 404
end
