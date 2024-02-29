require 'i18n'

get '/prensa' do
  @active_tab_prensa = 'active'
  @meta_tags.set! title: "#{t('meta_tag.press.title')}",
                  description: t('meta_tag.press.description'),
                  canonical: "#{t('meta_tag.press.canonical')}"
  # @kleerers = KeventerReader.instance.kleerers session[:locale]
#TODO: remove old news implementation and move to /novedades
  # @news = get_news
  # return erb :'news/index', layout: :'layout/layout2022'
  @news = News.create_list_keventer

  router_helper = RouterHelper.instance
  router_helper.alternate_route = "/"

  erb :'news_v2/index', layout: :'layout/layout2022'

end

get '/clientes/equipos-scrum-en-technisys-2015' do
  redirect '/prensa/casos/equipos-scrum-en-technisys-2015', 301 # permanent redirect
end

get '/prensa/casos/equipos-scrum-en-technisys-2015' do
  @meta_tags.set! title: 'Equipos de desarrollo Scrum y Automatización en Technisys'
  @meta_tags.set! description: 'Kleer - Coaching & Training - Equipos de desarrollo Scrum y
 automatización de despliegue de software en Technisys apoyados por Kleer'

  erb :'clients/old/prensa_casos_technisys_2015', layout: :'layout/layout2022'
end

get '/clientes/equipos-scrum-en-plataforma-10-2015' do
  redirect '/prensa/casos/equipos-scrum-en-plataforma-10-2015', 301 # permanent redirect
end

get '/prensa/casos/equipos-scrum-en-plataforma-10-2015' do
  @meta_tags.set! title: 'Equipos de desarrollo Scrum y Automatización en Plataforma 10'
  @meta_tags.set! description: 'Kleer - Coaching & Training - Equipos de desarrollo Scrum y
 orientación al valor para el negocio en Plataforma 10, apoyados por Kleer'

  erb :'clients/old/prensa_casos_plataforma_10_2015', layout: :'layout/layout2022'
end

get '/clientes/equipos-scrum-en-suramericana-2015' do
  redirect '/prensa/casos/equipos-scrum-en-suramericana-2015', 301 # permanent redirect
end

get '/prensa/casos/equipos-scrum-en-suramericana-2015' do
  @meta_tags.set! title: 'Paradigma ágil en tecnología y en negocio en Suramericana'
  @meta_tags.set! description: 'Kleer - Coaching & Training - Paradigma ágiles en tecnología y
 en negocio en Suramericana, apoyados por Kleer'

  erb :'clients/old/prensa_casos_suramericana_2015', layout: :'layout/layout2022'
end

get '/clientes/innovacion-en-marketing-digital-loreal-2016' do
  redirect '/prensa/casos/innovacion-en-marketing-digital-loreal-2016', 301 # permanent redirect
end

get '/prensa/casos/transformacion-agil-ypf-2020' do
  @meta_tags.set! title: 'Así profundizó YPF su camino de transformación ágil'
  @meta_tags.set! description: 'Kleer - Coaching & Training - Creación incremental y colaborativa de
 estrategias digitales facilitada por Kleer'

  erb :'clients/old/prensa_casos_ypf_2020', layout: :'layout/layout2022'
end

get '/prensa/casos/innovacion-en-marketing-digital-loreal-2016' do
  @meta_tags.set! title: "Innovación en Marketing Digital en L'Oréal"
  @meta_tags.set! description: 'Kleer - Coaching & Training - Creación incremental y colaborativa de
 estrategias digitales facilitada por Kleer'

  erb :'clients/old/prensa_casos_loreal_2016', layout: :'layout/layout2022'
end

get '/prensa/casos/transformacion-cultural-agil-ti-epm-2018' do
  @meta_tags.set! title: 'EPM se transforma culturalmente'
  @meta_tags.set! description: 'Kleer - Coaching & Training - Cómo acompañamos desde Kleer la transformación ágil de TI en EPM'

  erb :'clients/old/prensa_casos_epm_2018', layout: :'layout/layout2022'
end

get '/prensa/casos/transformacion-digital-bbva-continental' do
  @meta_tags.set! title: 'Acompañamiento en la transformación digital de BBVA Continental'
  @meta_tags.set! description: 'Kleer - Coaching & Training -Acompañamiento en la transformación digital de BBVA Continental'

  erb :'clients/old/prensa_casos_bbva_2018', layout: :'layout/layout2022'
end

get '/prensa/casos/falabella-financiero' do
  @meta_tags.set! title: '#ransformación Organizacional en Falabella Financiero'
  @meta_tags.set! description: 'Kleer - Coaching & Training - Transformación Organizacional en Falabella Financiero'

  erb :'clients/old/prensa_casos_falabella_financiero', layout: :'layout/layout2022'
end

get '/prensa/casos/afp-crecer' do
  @meta_tags.set! title: 'Coaching y transformación ágil en AFP Crecer'
  @meta_tags.set! description: 'Kleer - Coaching & Training - Coaching y transformación ágil en AFP Crecer'

  erb :'clients/old/prensa_casos_afp_crecer', layout: :'layout/layout2022'
end

get '/prensa/casos/capacitaciones-agiles-endava' do
  @meta_tags.set! title: 'Jornada de capacitaciones ágiles en Endava'
  @meta_tags.set! description: 'Kleer - Coaching & Training - Endava, una empresa internacional que ofrece servicios
 de desarrollo de software con presencia en Latinoamérica, Estados Unidos y Europa, se vio en el desafío de
 mantener la cultura ágil dentro de un contexto de gran crecimiento en poco tiempo.'

  erb :'clients/old/prensa_casos_endava_2018', layout: :'layout/layout2022'
end
