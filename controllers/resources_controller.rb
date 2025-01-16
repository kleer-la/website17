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

# get '/recursos/:slug' do |slug|
get %r{/(resources|recursos)/([^/]+)} do |_, slug|
  @active_tab_publicamos = 'active'
  @resource = Resource.create_one_keventer(slug, session[:locale])

  if slug != @resource.slug
    redirect to("/recursos/#{@resource.slug}"), 301
  end

  @meta_tags.set! title: @resource.tabtitle,
                  description: @resource.seo_description,
                  canonical: "#{t('meta_tag.resources.canonical')}/#{@resource.slug}",
                  image: @resource.cover

  @resource.long_description = @markdown_renderer.render(@resource.long_description)

  @also_download = @resource.also_download(3)
  erb :'resources/show/show', layout: :'layout/layout2022'
rescue ResourceNotFoundError
  return status 404
end
