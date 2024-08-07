require './lib/articles'

require './controllers/blog_home_data'
require './controllers/pager_helper'

get '/blog-preview/:slug' do |slug|
  @meta_tags.set! noindex: true, nofollow: true
  @where = 'Blog-Preview'

  blog_one Article.create_one_keventer(slug)
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
end

get %r{/blog/?} do
  @meta_tags.set! title: t('meta_tag.blog.title'),
                  description: t('meta_tag.blog.description'),
                  canonical: t('meta_tag.blog.canonical').to_s
  @where = 'Blog'

  @categories = load_categories session[:locale]

  articles = Article.create_list_keventer(true)
  @articles = articles.select { |a| a.lang == session[:locale] }.sort_by(&:created_at).reverse

  erb :'blog/index', layout: :'layout/layout2022'
end

def blog_one(article)
  @article = article
  @meta_tags.set! title: @article.tabtitle,
                  description: @article.description,
                  canonical: "#{t('meta_tag.blog.canonical')}/#{@article.slug}"

  router_helper = RouterHelper.instance
  router_helper.alternate_route = '/blog'

  if article.lang != session[:locale]
    redirect "/#{session[:locale]}/blog", 301 # permanent redirect
  end

  erb :'blog/landing_blog/index', layout: :'layout/layout2022'
end

def blog_list(articles)
  @meta_tags.set! title: t('meta_tag.blog.title'),
                  description: t('meta_tag.blog.description'),
                  canonical: t('meta_tag.blog.canonical').to_s

  @articles = articles
  erb :'blog/index', layout: :'layout/layout2022'
end
