get '/somos' do
  @active_tab_somos = 'active'
  meta_tags! title: "#{@base_title} | Somos"
  @kleerers = KeventerReader.instance.kleerers session[:locale]

  return erb :'about_us/index', layout: :'layout/layout2022' if session[:version] == 2022
  erb :somos
end

get '/nuestra-filosofia' do
  @active_tab_somos = 'active'
  meta_tags! title: "#{@base_title} | Nuestra filosofía"
  @kleerers = KeventerReader.instance.kleerers session[:locale]
  erb :nuestra_filosofia
end

get '/privacy' do
  @active_tab_privacidad = 'active'
  meta_tags! title: "#{@base_title} | Declaración de privacidad"
  erb :privacy
end

get '/terms' do
  @active_tab_terminos = 'active'
  meta_tags! title: "#{@base_title} | Terminos y condiciones"
  erb :terms
end
