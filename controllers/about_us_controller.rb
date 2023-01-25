get '/somos' do
  @active_tab_somos = 'active'
  @meta_tags.set! title: "#{t('meta_tag.aboutus.title')}",
                  description: t('meta_tag.aboutus.description'),
                  canonical: "#{session[:locale]}#{t('meta_tag.aboutus.canonical')}"
  @kleerers = KeventerReader.instance.kleerers session[:locale]

  erb :'about_us/index', layout: :'layout/layout2022'
end

get '/nuestra-filosofia' do
  @active_tab_somos = 'active'
  @meta_tags.set! title: "#{@base_title} | Nuestra filosofía"
  @kleerers = KeventerReader.instance.kleerers session[:locale]
  erb :nuestra_filosofia
end

get '/privacy' do
  @active_tab_privacidad = 'active'
  @meta_tags.set! title: "#{@base_title} | Declaración de privacidad"
  erb :privacy
end

get '/terms' do
  @active_tab_terminos = 'active'
  @meta_tags.set! title: "#{@base_title} | Terminos y condiciones"
  erb :terms
end
