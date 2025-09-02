require './lib/articles'

require './controllers/pager_helper'
require 'nokogiri'

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
  begin
    art = Article.create_one_keventer(slug)
    raise ArticleNotFoundError.new(slug) unless art.published

    if art.slug != slug
      redirect("#{session[:locale]}/blog/#{art.slug}", 301)
    else
      blog_one art
    end
  rescue ArticleNotFoundError => _e
    return status 404
  end
end

get %r{/blog/?} do
  page = Page.load_from_keventer(session[:locale], 'blog')
  @meta_tags.set! title: page.seo_title || t('meta_tag.blog.title'),
                  description: page.seo_description || t('meta_tag.blog.description'),
                  canonical: page.canonical || t('meta_tag.blog.canonical')

  @meta_tags.set! image: page.cover unless page.cover.nil?

  @where = 'Blog'

  @categories = load_categories session[:locale]

  articles = Article.create_list_keventer(true)
  @articles = articles.select { |a| a.lang == session[:locale] }

  erb :'blog/index', layout: :'layout/layout2022'
end

def blog_one(article)
  redirect "/#{session[:locale]}/blog", 301 if article.lang != session[:locale]

  @meta_tags.set! title: article.tabtitle,
                  description: article.description,
                  canonical: "#{t('meta_tag.blog.canonical')}/#{article.slug}",
                  noindex: article.noindex,
                  image: article.cover,
                  'last-modified': article.substantive_change_at

  router_helper = RouterHelper.instance
  router_helper.alternate_route = '/blog'

  rendered_body = @markdown_renderer.render(article.body)
  titles = extract_titles(rendered_body)
  body = set_ids_in_body(rendered_body, titles)

  @article = article
  erb :'blog/landing_blog/index', layout: :'layout/layout2022',
                                  locals: { titles: titles, body: body }
end

def blog_list(articles)
  @meta_tags.set! title: t('meta_tag.blog.title'),
                  description: t('meta_tag.blog.description'),
                  canonical: t('meta_tag.blog.canonical').to_s

  @articles = articles
  erb :'blog/index', layout: :'layout/layout2022'
end
