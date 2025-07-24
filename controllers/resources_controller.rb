require './lib/models/resources'
require './lib/models/assessment'

get %r{/(resources|recursos)/?} do
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

  lang = session[:locale] || 'es'
  partial_url = lang == 'es' ? 'recursos' : 'resources'

  if slug == 'retromat'
    redirect to("/#{lang}/#{partial_url}/retromat-planes-retrospectivas"), 301
  end
  
  @resource = Resource.create_one_keventer(slug, lang)
  
  if slug != @resource.slug
    redirect to("/#{lang}/#{partial_url}/#{@resource.slug}"), 301
  end
  @is_assessment = @resource.format == 'assessment'

  @meta_tags.set! title: @resource.tabtitle,
                  description: @resource.seo_description,
                  canonical: "#{t('meta_tag.resources.canonical')}/#{@resource.slug}",
                  image: @resource.cover

  @resource.long_description = @markdown_renderer.render(@resource.long_description)

  @also_download = unless @is_assessment 
                    @resource.also_download(3)
                  else
                    []
                  end
  erb :'resources/show/show', layout: :'layout/layout2022'
rescue ResourceNotFoundError
  return status 404
end

