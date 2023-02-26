require './lib/json_api'
require './lib/articles'

def filter_articles(article_list ,category = nil, page_number = nil, match = nil, all = nil)
  @filtered_list = article_list

  if category
    @filtered_list = @filtered_list.select{|e| e.category_name == category}
  end
  if match
    @filtered_list = @filtered_list.select{|e| e.title.downcase.include?(match.downcase) }
  end

  total = @filtered_list.length

  @selected = article_list.select{|e| e.selected}
  @q4page = all ? 9 : 6
  @filtered_list = @filtered_list[(page_number * @q4page)...(page_number * @q4page)+@q4page]

  return @filtered_list, total
end

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

get '/blog2022' do
  @meta_tags.set! title: t('meta_tag.blog.title'),
                  description: t('meta_tag.blog.description'),
                  canonical: "#{t('meta_tag.blog.canonical')}"
  @where = 'Blog'
  session[:version] = 2022

  @category = params[:category]
  @page_number = params[:page] ? params[:page].to_i : 0
  @match = params[:match]
  @all= params[:all]
  @q4page = 0

  @articles, @total = filter_articles(Article.create_list_keventer(true), @category, @page_number, @match, @all)

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

  if session[:version] == 2022
    erb :'blog/landing_blog/index', layout: :'layout/layout2022'
  else
    erb :'blog/article', layout: :'layout/layout2022'
  end

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
