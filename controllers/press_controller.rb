get '/clientes/equipos-scrum-en-technisys-2015' do
  redirect '/prensa/casos/equipos-scrum-en-technisys-2015', 301 # permanent redirect
end

get '/prensa/casos/equipos-scrum-en-technisys-2015' do
  meta_tags! title: 'Equipos de desarrollo Scrum y Automatización en Technisys'
  meta_tags! description: 'Kleer - Coaching & Training - Equipos de desarrollo Scrum y
 automatización de despliegue de software en Technisys apoyados por Kleer'
  @meta_keywords = 'Kleer, Technisys, CyberBank, scrum, equipos, desarrollo ágil,
 devops, automatización, integración continua, jenkins'

  erb :prensa_casos_technisys_2015
end

get '/clientes/equipos-scrum-en-plataforma-10-2015' do
  redirect '/prensa/casos/equipos-scrum-en-plataforma-10-2015', 301 # permanent redirect
end

get '/prensa/casos/equipos-scrum-en-plataforma-10-2015' do
  meta_tags! title: 'Equipos de desarrollo Scrum y Automatización en Plataforma 10'
  meta_tags! description: 'Kleer - Coaching & Training - Equipos de desarrollo Scrum y
 orientación al valor para el negocio en Plataforma 10, apoyados por Kleer'
  @meta_keywords = 'Kleer, Plataforma 10, scrum, equipos, desarrollo ágil, devops,
 automatización, integración continua, valor negocio'

  erb :prensa_casos_plataforma_10_2015
end

get '/clientes/equipos-scrum-en-suramericana-2015' do
  redirect '/prensa/casos/equipos-scrum-en-suramericana-2015', 301 # permanent redirect
end

get '/prensa/casos/equipos-scrum-en-suramericana-2015' do
  meta_tags! title: 'Paradigma ágil en tecnología y en negocio en Suramericana'
  meta_tags! description: 'Kleer - Coaching & Training - Paradigma ágiles en tecnología y
 en negocio en Suramericana, apoyados por Kleer'
  @meta_keywords = 'Kleer, Suramericana, Sura, scrum, equipos, desarrollo ágil, valor
 negocio, corporaciones ágiles, paradigma ágil en las empresas'

  erb :prensa_casos_suramericana_2015
end

get '/clientes/innovacion-en-marketing-digital-loreal-2016' do
  redirect '/prensa/casos/innovacion-en-marketing-digital-loreal-2016', 301 # permanent redirect
end

get '/prensa/casos/transformacion-agil-ypf-2020' do
  meta_tags! title: 'Así profundizó YPF su camino de transformación ágil'
  meta_tags! description: 'Kleer - Coaching & Training - Creación incremental y colaborativa de
 estrategias digitales facilitada por Kleer'
  @meta_keywords = "Kleer, L'Oréal, Loreal, Innovación, Design Thinking, facilitación,
 coloaboración, facilitación gráfica, marketing, digital"

  erb :prensa_casos_ypf_2020
end

get '/prensa/casos/innovacion-en-marketing-digital-loreal-2016' do
  meta_tags! title: "Innovación en Marketing Digital en L'Oréal"
  meta_tags! description: 'Kleer - Coaching & Training - Creación incremental y colaborativa de
 estrategias digitales facilitada por Kleer'
  @meta_keywords = "Kleer, L'Oréal, Loreal, Innovación, Design Thinking, facilitación,
 coloaboración, facilitación gráfica, marketing, digital"

  erb :prensa_casos_loreal_2016
end

get '/prensa/casos/transformacion-cultural-agil-ti-epm-2018' do
  meta_tags! title: 'EPM se transforma culturalmente'
  meta_tags! description: 'Kleer - Coaching & Training - Cómo acompañamos desde Kleer la transformación ágil de TI en EPM'
  @meta_keywords = 'Kleer, epm, empresas publicas medellin, scrum, equipos, coaching, cambio cultural, agilidad,
 agile, caso de exito, sistemas, ti, mejora continua, transformación organizacional, evolución organizacional'

  erb :prensa_casos_epm_2018
end

get '/prensa/casos/transformacion-digital-bbva-continental' do
  meta_tags! title: 'Acompañamiento en la transformación digital de BBVA Continental'
  meta_tags! description: 'Kleer - Coaching & Training -Acompañamiento en la transformación digital de BBVA Continental'
  @meta_keywords = 'Kleer, scrum, equipos, coaching, cambio cultural, agilidad, agile, caso de exito, mejora
 continua, transformación organizacional, evolución organizacional'

  erb :prensa_casos_bbva_2018
end

get '/prensa/casos/falabella-financiero' do
  meta_tags! title: '#ransformación Organizacional en Falabella Financiero'
  meta_tags! description: 'Kleer - Coaching & Training - Transformación Organizacional en Falabella Financiero'
  @meta_keywords = 'Kleer, scrum, equipos, coaching, cambio cultural, agilidad, agile, caso de exito, mejora
 continua, transformación organizacional, evolución organizacional'

  erb :prensa_casos_falabella_financiero
end

get '/prensa/casos/afp-crecer' do
  meta_tags! title: 'Coaching y transformación ágil en AFP Crecer'
  meta_tags! description: 'Kleer - Coaching & Training - Coaching y transformación ágil en AFP Crecer'
  @meta_keywords = 'Kleer, scrum, equipos, coaching, cambio cultural, agilidad, agile, caso de exito, mejora
 continua, transformación organizacional, evolución organizacional'

  erb :prensa_casos_afp_crecer
end

get '/prensa/casos/capacitaciones-agiles-endava' do
  meta_tags! title: 'Jornada de capacitaciones ágiles en Endava'
  meta_tags! description: 'Kleer - Coaching & Training - Endava, una empresa internacional que ofrece servicios
 de desarrollo de software con presencia en Latinoamérica, Estados Unidos y Europa, se vio en el desafío de
 mantener la cultura ágil dentro de un contexto de gran crecimiento en poco tiempo.'
  @meta_keywords = 'Kleer, Agile training, Scrum, Kanban, Trabajo en equipo, Capacitación'

  erb :prensa_casos_endava_2018
end
