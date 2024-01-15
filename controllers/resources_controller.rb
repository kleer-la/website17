require './lib/resources'


get '/recursos' do
  @active_tab_publicamos = 'active'
  @meta_tags.set!  title: t('meta_tag.resources.title'),
                   description: t('meta_tag.resources.description'),
                   canonical: "#{t('meta_tag.resources.canonical')}"

  @resources = Resource.create_list_keventer
  session[:new] = false

  erb :'resources/index', layout: :'layout/layout2022'
end

get '/recursos/primeros_pasos' do
  @active_tab_publicamos = 'active'
  @meta_tags.set! title: "#{@base_title} | Recursos"
  erb :'old_page/recursos/recursos_primeros_pasos'
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
