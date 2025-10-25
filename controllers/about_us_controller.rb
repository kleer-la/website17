get %r{/(somos|about_us)/?} do
  page = Page.load_from_keventer(session[:locale], 'somos')
  @meta_tags.set! title: page.seo_title || t('meta_tag.aboutus.title'),
                  description: page.seo_description || t('meta_tag.aboutus.description'),
                  canonical: page.canonical || t('meta_tag.aboutus.canonical')
  @meta_tags.set! image: page.cover unless page.cover.nil?

  @active_tab_somos = 'active'
  @kleerers = Trainer.create_keventer_json session[:locale]

  router_helper = RouterHelper.instance
  router_helper.alternate_route = RouterHelper.alternate_path('somos', session[:locale])

  erb :'about_us/index', layout: :'layout/layout2022'
end

get '/nuestra-filosofia' do
  @active_tab_somos = 'active'
  @meta_tags.set! title: "#{@base_title} | Nuestra filosofía"
  @kleerers = Trainer.create_keventer_json session[:locale]
  erb :'old_page/nuestra_filosofia', layout: :'layout/layout2022'
end

get '/privacy' do
  @active_tab_privacidad = 'active'
  @meta_tags.set! title: t('privacy.title')

  erb :'about_us/privacy', layout: :'layout/layout2022'
end

get '/terms' do
  @active_tab_terminos = 'active'
  @meta_tags.set! title: t('terms.title')

  erb :'about_us/terms', layout: :'layout/layout2022'
end
