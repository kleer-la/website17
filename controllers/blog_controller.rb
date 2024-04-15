require './lib/json_api'
require './lib/articles'

require './controllers/blog_home_data'
require './controllers/pager_helper'

get '/blog/' do
  redirect '/blog', 301 # permanent redirect
end

get '/blog-preview/:slug' do |slug|
  @meta_tags.set! noindex: true, nofollow: true
  @where = 'Blog-Preview'

  begin
    blog_one Article.create_one_keventer(slug)
  rescue
    status 404
  end
end

get '/blog-preview' do
  @meta_tags.set! noindex: true, nofollow: true

  @where = 'Blog-Preview'

  blog_list Article.create_list_keventer(false)
end

get '/blog/:slug' do |slug|
  @where = 'Blog'
  art = Article.create_one_keventer(slug)
  redirect("#{session[:locale]}/blog/#{art.slug}", 301) if art.slug != slug
  blog_one art
rescue
  status 404
end

get '/blog' do
  @meta_tags.set! title: t('meta_tag.blog.title'),
                  description: t('meta_tag.blog.description'),
                  canonical: "#{t('meta_tag.blog.canonical')}"
  @where = 'Blog'

  @categories = load_categories session[:locale]

  articles = Article.create_list_keventer(true)

  @articles = articles.select { |a| a.lang == session[:locale]}.sort_by(&:created_at).reverse

  erb :'blog/index', layout: :'layout/layout2022'
end

def blog_one(article)
  @article = article
  @meta_tags.set! title: @article.tabtitle,
                  description: @article.description,
                  canonical: "#{t('meta_tag.blog.canonical')}/#{@article.slug}"

  @related_courses = get_related_event_types(@article.category_name, @article.id , 4)
  @related_articles = get_related_articles(@article.category_name, @article.id , 3)

  router_helper = RouterHelper.instance
  router_helper.alternate_route = "/blog"

  if article.lang != session[:locale]
    redirect "/#{session[:locale]}/blog", 301 # permanent redirect
  end

  erb :'blog/landing_blog/index', layout: :'layout/layout2022'

rescue
  status 404
end

def blog_list(articles)
  @meta_tags.set! title: t('meta_tag.blog.title'),
                  description: t('meta_tag.blog.description'),
                  canonical: "#{t('meta_tag.blog.canonical')}"

  @articles = articles
  erb :'blog/index', layout: :'layout/layout2022'

rescue
  status 404
end
