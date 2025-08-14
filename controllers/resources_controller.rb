require './lib/models/resources'
require './lib/models/assessment'

get %r{/(resources|recursos)/?} do
  resources_index
end
get %r{/(resources|recursos)/preview/?} do
  resources_index(preview:true)
end

def resources_index(preview=false)
  page = Page.load_from_keventer(session[:locale], 'recursos')
  @meta_tags.set! title: page.seo_title || t('meta_tag.resources.title'),
                  description: page.seo_description || t('meta_tag.resources.description'),
                  canonical: page.canonical || t('meta_tag.resources.canonical')

  @meta_tags.set! image: page.cover unless page.cover.nil?

  @active_tab_publicamos = 'active'
  if preview
    @resources = Resource.create_list_keventer(:resources_preview_url)
  else
  @resources = Resource.create_list_keventer
  end

  erb :'resources/index', layout: :'layout/layout2022'
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

