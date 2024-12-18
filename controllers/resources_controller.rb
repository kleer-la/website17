require './lib/models/resources'

get '/recursos' do
  page = Page.load_from_keventer(session[:locale], 'recursos')
  @meta_tags.set! title: page.seo_title || t('meta_tag.resources.title'),
                  description: page.seo_description || t('meta_tag.resources.description'),
                  canonical: page.canonical || t('meta_tag.resources.canonical')

  @meta_tags.set! image: page.cover unless page.cover.nil?

  @active_tab_publicamos = 'active'
  @resources = Resource.create_list_keventer

  erb :'resources/index', layout: :'layout/layout2022'
end

get '/recursos/primeros_pasos' do
  @active_tab_publicamos = 'active'
  @meta_tags.set! title: "#{@base_title} | Recursos"
  erb :'old_page/recursos/recursos_primeros_pasos', layout: :'layout/layout2022'
end

get '/publicamos/scrum' do
  @active_tab_publicamos = 'active'
  @meta_tags.set! title: "#{@base_title} | Publicamos | Proyectos Ágiles con Scrum"
  erb :'old_page/recursos/ebook_scrum_plain', layout: :layout_ebook_landing
end

get '/mas-productivos' do
  redirect '/publicamos/mas-productivos', 301 # permanent redirect
end

get '/publicamos/mas-productivos' do
  @active_tab_publicamos = 'active'
  @meta_tags.set! title: "#{@base_title} | Publicamos | Equipos más productivos"
  erb :'old_page/recursos/ebook_masproductivos_plain', layout: :layout_ebook_landing
end

get '/recursos/:slug' do |slug|
  @active_tab_publicamos = 'active'
  @resource = Resource.create_one_keventer(slug)

  @meta_tags.set! title: "#{@base_title} | #{@resource.title}",
                  description: @resource.description

  @resource.long_description = @markdown_renderer.render(@resource.long_description)

  erb :'resources/show/show', layout: :'layout/layout2022'
rescue ResourceNotFoundError
  return status 404
end
