require './lib/models/resources'
require './lib/models/assessment'

get %r{/(resources|recursos)/?} do
  resources_index
end
get %r{/(resources|recursos)/preview/?} do
  resources_index(preview: true)
end

def resources_index(preview = false)
  page = Page.load_from_keventer(session[:locale], 'recursos')
  @meta_tags.set! title: page.seo_title || t('meta_tag.resources.title'),
                  description: page.seo_description || t('meta_tag.resources.description'),
                  canonical: page.canonical || t('meta_tag.resources.canonical')

  @meta_tags.set! image: page.cover unless page.cover.nil?

  @active_tab_publicamos = 'active'
  @resources = if preview
                 Resource.create_list_keventer(:resources_preview_url)
               else
                 Resource.create_list_keventer
               end

  render_page :'resources/index'
end

# get '/recursos/:slug' do |slug|
# The languages a resource can be read in. It exists in one unless its
# translation really is there: offering /en/resources/<Spanish slug> named a
# page that answers 302 to the index, and an alternate that does not answer
# back is a pair Google drops — the same shape courses got rid of by declaring
# the one language they have. Setting the switcher's route is the same
# question, so it is asked once.
def resource_alternates(base_path, slug, lang, resource)
  alternate_slug = RouterHelper.instance.set_alternate_route_with_fallback(base_path, slug, lang, Resource)
  paths = { lang.to_sym => "/#{RouterHelper.translate_path(base_path, lang)}/#{resource.slug}" }
  return paths unless alternate_slug

  other_lang = lang == 'es' ? 'en' : 'es'
  paths.merge(other_lang.to_sym => "/#{RouterHelper.translate_path(base_path, other_lang)}/#{alternate_slug}")
end

get %r{/(resources|recursos)/([a-z0-9_-]+)} do |base_path, slug|
  @active_tab_publicamos = 'active'

  lang = session[:locale] || 'es'
  partial_url = lang == 'es' ? 'recursos' : 'resources'

  redirect to("/#{lang}/#{partial_url}/retromat-planes-retrospectivas"), 301 if slug == 'retromat'

  @resource = Resource.create_one_keventer(slug, lang)

  redirect to("/#{lang}/#{partial_url}/#{@resource.slug}"), 301 if slug != @resource.slug

  # Check if resource has content in the requested language
  if @resource.title.to_s.strip.empty?
    flash[:error] = t('resources.not_found')
    redirect to("/#{lang}/#{partial_url}")
  end
  @is_assessment = @resource.format == 'assessment'

  alternates = resource_alternates(base_path, slug, lang, @resource)

  @meta_tags.set! title: @resource.tabtitle,
                  description: @resource.seo_description,
                  canonical: "#{t('meta_tag.resources.canonical')}/#{@resource.slug}",
                  image: @resource.cover,
                  hreflang: alternates.keys,
                  alternate_paths: alternates

  @json_ld = resource_json_ld(@resource)

  @resource.long_description = @markdown_renderer.render(@resource.long_description)

  @also_download = if @is_assessment
                     []
                   else
                     @resource.also_download(3)
                   end

  render_page :'resources/show/show'
rescue ResourceNotFoundError
  return status 404
end
