get %r{/(somos|about_us)/?} do
  page = Page.load_from_keventer(session[:locale], 'somos')
  @meta_tags.set! title: page.seo_title || t('meta_tag.aboutus.title'),
                  description: page.seo_description || t('meta_tag.aboutus.description'),
                  canonical: page.canonical || t('meta_tag.aboutus.canonical'),
                  alternate_paths: RouterHelper.alternate_paths('somos')
  @meta_tags.set! image: page.cover unless page.cover.nil?

  @active_tab_somos = 'active'
  @kleerers = Trainer.create_keventer_json session[:locale]

  router_helper = RouterHelper.instance
  router_helper.alternate_route = RouterHelper.alternate_path('somos', session[:locale])

  render_page :'about_us/index'
end

get '/nuestra-filosofia' do
  @active_tab_somos = 'active'
  @meta_tags.set! title: "#{@base_title} | Nuestra filosofía"
  @kleerers = Trainer.create_keventer_json session[:locale]
  render_page :'old_page/nuestra_filosofia'
end

get '/privacy' do
  @active_tab_privacidad = 'active'
  @meta_tags.set! title: t('privacy.title')

  render_page :'about_us/privacy'
end

get '/terms' do
  @active_tab_terminos = 'active'
  @meta_tags.set! title: t('terms.title')

  render_page :'about_us/terms'
end
