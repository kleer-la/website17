require './lib/clients'

# The clients page has no English edition: its cases do not exist in English,
# and the page promised testimonials it did not show. /en is cut to what it has
# (#404), so the English URL sends its visitors to About us.
get %r{/(clientes|clients)/?} do
  redirect to('/en/about_us'), 301 if session[:locale].to_s == 'en'

  page = Page.load_from_keventer(session[:locale], 'clientes')
  @meta_tags.set! title: page.seo_title || t('meta_tag.clients.title'),
                  description: page.seo_description || t('meta_tag.clients.description'),
                  canonical: page.canonical || t('meta_tag.clients.canonical'),
                  hreflang: [:es]

  @meta_tags.set! image: page.cover unless page.cover.nil?

  @page = page
  @clients = client_list
  @articles = Article.create_list_keventer(true)
                     .select { |a| a.lang == session[:locale] && a.industry != '' }
                     .sort_by(&:created_at).reverse

  RouterHelper.instance.alternate_route = '/about_us'
  render_page :'clients/index'
end

get '/clientes/testimonios/:id' do
  redirect("#{session[:locale]}/blog/#{params[:id]}", 301)
end

def redirect_not_found_testimony
  # Persisted flash (not flash.now) so it survives the redirect; :error is the
  # key the layout's _flash_messages partial renders.
  flash[:error] = I18n.t('page_not_found')
  lang = session[:locale]
  redirect(to(lang.to_s == 'en' ? '/en/about_us' : '/es/clientes'))
end
