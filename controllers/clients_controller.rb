require './lib/clients'

get '/clientes' do
  page = Page.load_from_keventer(session[:locale], 'clientes')
  @meta_tags.set! title: page.seo_title || t('meta_tag.clients.title'),
                  description: page.seo_description || t('meta_tag.clients.description'),
                  canonical: page.canonical || t('meta_tag.clients.canonical')

  @meta_tags.set! image: page.cover unless page.cover.nil?

  @clients = client_list
  @stories = success_stories
  erb :'clients/index_ng', layout: :'layout/layout2022'
end

get '/clientes2' do
  page = Page.load_from_keventer(session[:locale], 'clientes')
  @meta_tags.set! title: page.seo_title || t('meta_tag.clients.title'),
                  description: page.seo_description || t('meta_tag.clients.description'),
                  canonical: page.canonical || t('meta_tag.clients.canonical')

  @meta_tags.set! image: page.cover unless page.cover.nil?

  @clients = client_list
  @articles = Article.create_list_keventer(true)
                     .select { |a| a.lang == session[:locale] && a.industry != '' }
                     .sort_by(&:created_at).reverse

  erb :'clients/index', layout: :'layout/layout2022'
end

get '/clientes/testimonios/:id' do
  slug = params[:id]
  # TODO: temporary code
  @where = 'Blog'
  art = Article.create_one_keventer(slug)
  redirect("#{session[:locale]}/blog/#{art.slug}", 301) if art.slug != slug
  blog_one art
rescue ArticleNotFoundError => _e
  story = success_stories(params[:id])
  return(redirect_not_found_testimony) if story.nil?

  @meta_tags.set! title: story[:title],
                  description: story[:meta_desdription],
                  canonical: request.path
  erb :'clients/success_story', locals: { story: story }, layout: :'layout/layout2022'
end

def redirect_not_found_testimony
  session[:error_msg] = I18n.t('page_not_found')
  flash.now[:alert] = I18n.t('page_not_found')
  redirect(to("/#{session[:locale]}/clientes"))
end
