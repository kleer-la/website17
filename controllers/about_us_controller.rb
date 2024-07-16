get '/somos' do
  @active_tab_somos = 'active'
  @meta_tags.set! title: t('meta_tag.aboutus.title').to_s,
                  description: t('meta_tag.aboutus.description'),
                  canonical: t('meta_tag.aboutus.canonical').to_s
  @kleerers = Trainer.create_keventer_json session[:locale]

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
