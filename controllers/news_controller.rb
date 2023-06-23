require './lib/news'


get '/novedades' do
  @active_tab_publicamos = 'active'
  # @meta_tags.set!  title: t('meta_tag.resources.title'),
  #                  description: t('meta_tag.resources.description'),
  #                  canonical: "#{t('meta_tag.resources.canonical')}"

  @news = News.create_list_keventer
  
  erb :'news_v2/index', layout: :'layout/layout2022'
end
