require './lib/models/news'

get %r{/prensa|/novedades|/news} do
  news_index
end

get '/novedades/preview' do
  news_index(preview:true)
end

def news_index(preview=false)
  @page = Page.load_from_keventer(session[:locale], 'novedades')
  @meta_tags.set! title: @page.seo_title || t('meta_tag.news.title'),
                  description: @page.seo_description || t('meta_tag.news.description'),
                  canonical: @page.canonical || t('meta_tag.news.canonical')

  @meta_tags.set! image: @page.cover unless @page.cover.nil?

  @active_tab_publicamos = 'active'
  if preview
    @news = News.create_list_keventer(:news_preview_url)
  else
    @news = News.create_list_keventer
  end

  router_helper = RouterHelper.instance
  router_helper.alternate_route = '/'

  erb :'news/preview', layout: :'layout/layout2022'
end