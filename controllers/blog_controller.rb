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

get '/blog/:slug' do |slug|
  @where = 'Blog'
  blog_one Article.create_one_keventer(slug)
rescue StandardError => e
  puts e
  status 404
end

get '/blog' do
  @meta_tags.set! title: t('meta_tag.blog.title'),
                  description: t('meta_tag.blog.description'),
                  canonical: "#{t('meta_tag.blog.canonical')}"
  @where = 'Blog'

  # TODO: deprecate

  # @category = params[:category]
  # @match = params[:match]
  # @all= params[:all]
  # @all= true if session[:locale] == 'en'  # always 'all' for English
  #
  @categories = load_categories session[:locale]

  articles = Article.create_list_keventer(true)

  # @blog_home_data = BlogHomeData.new(articles, session[:locale])
  # @blog_home_data.filter_by_category(@category).filter_by_text(@match)
  #
  # @pager = Pager.new(
  #   @all ? 9 : 6,
  #   @blog_home_data.filtered(@all).count
  # ).on_page(params[:page] ? params[:page].to_i : 0)
  # @articles = @pager.filter(@blog_home_data.filtered(@all) )

  @articles = articles.select { |a| a.lang == session[:locale]}.sort_by(&:created_at).reverse

  @show_abstract = true
  erb :'blog/index', layout: :'layout/layout2022'
end

def blog_one(article)
  @article = article
  @meta_tags.set! title: @article.tabtitle,
                  description: @article.description,
                  canonical: "#{t('meta_tag.blog.canonical')}/#{@article.slug}"

  @related_courses = get_related_event_types(@article.category_name, @article.id , 4)
  @related_articles = get_related_articles(@article.category_name, @article.id , 3)

  if article.lang != session[:locale]
    redirect "/#{session[:locale]}/blog", 301 # permanent redirect
  end

  erb :'blog/landing_blog/index', layout: :'layout/layout2022'

rescue StandardError => e
  puts e
  status 404
end

def blog_list(articles)
  @meta_tags.set! title: t('meta_tag.blog.title'),
                  description: t('meta_tag.blog.description'),
                  canonical: "#{t('meta_tag.blog.canonical')}"

  @articles = articles
  @show_abstract = true
  erb :'blog/index', layout: :'layout/layout2022'

rescue StandardError => e
  puts e
  status 404
end
