require 'i18n'

def get_news
  [
    { title: I18n.t('press.release36_title'),
      subtitle: 'iPro UP - 10.5.22',
      text: I18n.t('press.release36_text'),
      url: 'https://www.iproup.com/innovacion/31364-mejora-continua-como-crear-el-habito-con-impacto-para-tu-negocio',
      img: 'https://kleer-images.s3.sa-east-1.amazonaws.com/news/leo-agudelo-en-ipro-up.png'
    },
    { title: I18n.t('press.release35_title'),
      subtitle: 'cio.com.mx - 15.4.21',
      text: I18n.t('press.release35_text'),
      url: 'https://cio.com.mx/nueve-practicas-para-potenciar-la-colaboracion-de-equipos-distribuidos/',
      img: 'https://kleer-images.s3.sa-east-1.amazonaws.com/news/veronica-arganaraz-en-cio-mx.jpg'
    },
    { title: I18n.t('press.release34_title'),
      subtitle: 'revistaeconomia.com - 14.4.21',
      text: I18n.t('press.release34_text'),
      url: 'https://www.revistaeconomia.com/9-practicas-clave-para-potenciar-la-colaboracion-distribuida',
      img: 'https://kleer-images.s3.sa-east-1.amazonaws.com/news/veronica-arganaraz-en-revista-economica.jpg'
    },
    { title: I18n.t('press.release33_title'),
      subtitle: 'acis.org.co - Abril 2021',
      text: I18n.t('press.release33_text'),
      url: 'https://acis.org.co/portal/content/noticiasdeinteres/9-pr%C3%A1cticas-clave-para-potenciar-la-colaboraci%C3%B3n-distribuida',
      img: '/img/prensa/prensa-33.jpg'
    },
    { title: I18n.t('press.release32_title'),
      subtitle: 'convergencialatina.com - 6.5.20',
      text: I18n.t('press.release32_text'),
      url: 'http://www.convergencialatina.com/Nota-Desarrollo/313104-3-9-La_fuerza_de_trabajo_paso_a_estar_en_un_90_en_hogares_la_tecnologia_existe_pero_faltan_procesos_y_cultura',
      img: '/img/prensa/prensa-32.jpg'
    },
    { title: I18n.t('press.release31_title'),
      subtitle: 'searchdatacenter.techtarget.com - 29.4.20',
      text: I18n.t('press.release31_text'),
      url: 'https://searchdatacenter.techtarget.com/es/cronica/Teletrabajo-en-pandemia-entornos-distribuidos-y-liderazgo-virtual',
      img: '/img/prensa/prensa-31.jpg'
    },
    { title: I18n.t('press.release30_title'),
      subtitle: 'clarin.com - 29.3.20',
      text: I18n.t('press.release30_text'),
      url: 'https://www.clarin.com/economia/cuarentena-obligatoria-teletrabajo-llego-quedarse-_0_Q8MJN7pgz.html',
      img: '/img/prensa/prensa-30.jpg'
    },
    { title: I18n.t('press.release29_title'),
      subtitle: 'lanacion.com - 1.10.19',
      text: I18n.t('press.release29_text'),
      url: 'https://www.lanacion.com.ar/lifestyle/umbral-maya-se-puede-innovar-todo-tiempo-nid2292651',
      img: '/img/prensa/prensa-29.jpg'
    },
    { title: I18n.t('press.release28_title'),
      subtitle: 'DiarioTi.com - 05.08.19',
      text: I18n.t('press.release28_text'),
      url: 'https://diarioti.com/opinion-que-es-lo-esencial-para-una-transformacion-organizacional-exitosa/110448',
      img: '/img/prensa/prensa-28.jpg'
    },
    { title: I18n.t('press.release27_title'),
      subtitle: 'Canal Ar - 20.5.19',
      text: I18n.t('press.release27_text'),
      url: 'https://www.canal-ar.com.ar/27949-Que-es-eso-de-la-agilidad-Existe-mas-alla-del-software.html',
      img: '/img/prensa/prensa-27.jpg'
    },
    { title: I18n.t('press.release26_title'),
      subtitle: 'Libreta de apuntes - 10.04.2019',
      text: I18n.t('press.release26_text'),
      url: 'https://libretadeapuntes.com/2019/04/como-saber-si-estamos-desarrollando-el-producto-equivocado/',
      img: '/img/prensa/libreta.jpg'
    },
    { title: I18n.t('press.release25_title'),
      subtitle: 'BAE Negocios - 01.04.2019',
      text: I18n.t('press.release25_text'),
      url: 'https://www.baenegocios.com/edicion-impresa/La-union-hace-la-fuerza-coaching-de-equipos-20190331-0028.html',
      img: '/img/prensa/bae-coaching.jpg'
    },
    { title: I18n.t('press.release24_title'),
      subtitle: 'Latinspots.com - 15.03.2019',
      text: I18n.t('press.release24_text'),
      url: 'https://www.latinspots.com/sp/empresas-y-negocios/detalle/19896/kleer-participa-en-el-scrum-day-colombia-con-una-charla-sobre-agilidad',
      img: '/img/prensa/latincolombia.jpg'
    },
    { title: I18n.t('press.release23_title'),
      subtitle: 'Canal Ar - 6.11.2018',
      text: I18n.t('press.release23_text'),
      url: 'https://www.canal-ar.com.ar/27488-Del-error-al-aprendizaje-en-el-camino-hacia-el-exito-temprano.html',
      img: '/img/prensa/canala2.jpg'
    },
    { title: I18n.t('press.release22_title'),
      subtitle: 'Totalmedios.com - 10.09.2018',
      text: I18n.t('press.release22_text'),
      url: 'https://www.totalmedios.com/nota/36141/8-amenazas-de-la-transformacion-digital-a-las-empresas-tradicionales',
      img: '/img/prensa/total-medios.jpg'
    },
    { title: I18n.t('press.release21_title'),
      subtitle: 'infochannel.info - 16.04.2018',
      text: I18n.t('press.release21_text'),
      url: 'https://www.infochannel.info/como-iniciar-la-transformacion-organizacional',
      img: '/img/prensa/infochannel.jpg'
    },
    { title: I18n.t('press.release20_title'),
      subtitle: 'Argendustria - 13.04.2018',
      text: I18n.t('press.release20_text'),
      url: 'http://argendustria.com.ar/nueve-decisiones-clave-para-iniciar-la-transformacion-organizacional/',
      img: '/img/prensa/argendustria.jpg'
    },
    { title: I18n.t('press.release19_title'),
      subtitle: 'somos-pymes.com - 01.02.2018',
      text: I18n.t('press.release18_text'),
      url: 'http://www.somos-pymes.com/noticias/economia/como-aprovechar-las-horas-para-ser-mas-productivo-y-descansar.html',
      img: '/img/prensa/descanso.jpg'
    },
    { title: I18n.t('press.release18_title'),
      subtitle: 'lanacion.com - 01.02.2018',
      text: I18n.t('press.release18_text'),
      url: 'https://www.lanacion.com.ar/2105093-tiempo-que-has-de-usar-como-aprovechar-las-horas-para-ser-mas-productivo-y-descansar',
      img: '/img/prensa/tiempodescanso.jpg'
    },
    { title: I18n.t('press.release17_title'),
      subtitle: 'CCSur - 25.01.2017',
      text: I18n.t('press.release17_text'),
      url: 'https://ccsur.com/congreso-regional-interaccion-clientes-2017/',
      img: '/img/prensa/congreso.jpg'
    },
    { title: I18n.t('press.release16_title'),
      subtitle: 'Canal Ar - 05.04.2017',
      text: I18n.t('press.release16_text'),
      url: 'https://www.canal-ar.com.ar/24139-RRHH-podria-matar-la-agilidad-de-tu-empresa--o-potenciarla.html',
      img: '/img/prensa/canalar.jpg'
    },
    { title: I18n.t('press.release15_title'),
      subtitle: 'Latinspots.com y Totalmedios.com - 10.02.2017',
      text: I18n.t('press.release15_text'),
      url: 'https://www.totalmedios.com/nota/30798/cultura-agil-y-cultura-latina-son-compatibles',
      img: '/img/prensa/cultura2.jpg'
    },
    { title: I18n.t('press.release14_title'),
      subtitle: 'issuu.com - 14.09.2016',
      text: I18n.t('press.release14_text'),
      url: 'https://issuu.com/sociosonline/docs/s24-issuu/55',
      img: '/img/prensa/facilitacion.jpg'
    },
    { title: I18n.t('press.release13_title'),
      subtitle: 'apertura.com - 19.05.2016',
      text: I18n.t('press.release13_text'),
      url: 'https://www.apertura.com/management/De-que-se-trata-la-metodologia-de-trabajo-inspirada-en-el-rubgy-que-quiere-ganar-terreno-en-las-empresas-20160519-0005.html',
      img: '/img/prensa/rugby.jpg'
    },
    { title: I18n.t('press.release12_title'),
      subtitle: 'lanacion.com - 03.10.2015',
      text: I18n.t('press.release12_text'),
      url: 'https://www.lanacion.com.ar/1833251-la-ropa-no-se-negocia',
      img: '/img/prensa/ropa.jpg'
    },
    { title: I18n.t('press.release11_title'),
      subtitle: 'ElContact.com - 18/Ago/2015',
      text: I18n.t('press.release11_text'),
      url: 'http://www.elcontact.com/2015/08/kleer-sera-anfitrion-de-la-1-jornada-de.html',
      img: '/img/prensa/1ra-jornada-de-metacreatividad.png'
    },
    { title: I18n.t('press.release10_title'),
      subtitle: 'LatinSpots.com - 10/Jul/2015',
      text: I18n.t('press.release10_text'),
      url: 'http://www.latinspots.com/site/sp/nota/detalle/36734/5-beneficios-de-las-agencias-ms-giles',
      img: '/img/prensa/5-beneficios-de-las-agencias-agiles.png'
    },
    { title: I18n.t('press.release09_title'),
      subtitle: 'Canal AR - 8/Jul/2015',
      text: I18n.t('press.release09_text'),
      url: 'https://canal-ar.com.ar/21854-7-claves-del-Coaching-de-Equipos.html',
      img: '/img/prensa/7-claves-del-coaching-de-equipos.png'
    },
    { title: I18n.t('press.release08_title'),
      subtitle: 'CustomerIn - Radio Palermo - 7/Jul/2015',
      text: I18n.t('press.release08_text'),
      url: 'https://www.youtube.com/embed/edh5xz7vyUI',
      img: 'https://kleer-images.s3.sa-east-1.amazonaws.com/news/pablo-tortorella-en-radio-palermo.png',
      video: 'https://www.youtube.com/embed/edh5xz7vyUI'
    },
    { title: I18n.t('press.release07_title'),
      subtitle: 'CIO Perú - 7/Jul/2015',
      text: I18n.t('press.release07_text'),
      url: 'http://cioperu.pe/articulo/19181/como-el-tipo-de-contrato-puede-condicionar-un-proyecto-complejo/',
      img: '/img/prensa/cio-peru-2015.png'
    },
    { title: I18n.t('press.release06_title'),
      subtitle: 'La burbuja - Radio Milenium - 5/Jul/2015',
      text: I18n.t('press.release06_text'),
      url: 'https://soundcloud.com/kleer_agile_coaching_and_training/entrevista-a-carlos-peix-en-radio-fm-milenium-1067?utm_source=www.kleer.la&utm_campaign=wtshare&utm_medium=widget&utm_content=https%253A%252F%252Fsoundcloud.com%252Fkleer_agile_coaching_and_training%252Fentrevista-a-carlos-peix-en-radio-fm-milenium-1067',
      img: 'https://kleer-images.s3.sa-east-1.amazonaws.com/news/carlos-peix-en-programa-la-burbuja.png',
      audio: 'https://w.soundcloud.com/player/?url=https%3A//api.soundcloud.com/tracks/218800859&amp;auto_play=false&amp;hide_related=false&amp;show_comments=true&amp;show_user=true&amp;show_reposts=false&amp;visual=true'
    },
    { title: I18n.t('press.release05_title'),
      subtitle: 'CCSur - 16/Jun/2015',
      text: I18n.t('press.release05_text'),
      url: 'http://www.ccsur.com/kleer-participara-en-agile-open-spain-2015/',
      img: '/img/prensa/kleer-en-el-aos.png'
    },
    { title: I18n.t('press.release04_title'),
      subtitle: 'CRONISTA.COM - 3/Abr/2014',
      text: I18n.t('press.release04_text'),
      url: 'http://www.cronista.com/pyme/Una-tribu-de-coaches-que-hace-escuela-en-la-region-20140403-0010.html',
      img: '/img/prensa/tribu-de-coaches.jpg'
    },
    { title: I18n.t('press.release03_title'),
      subtitle: 'PulsoSocial - 7/Mar/2014',
      text: I18n.t('press.release03_text'),
      url: 'https://pulsosocial.com/2014/03/07/scrum-el-adios-para-siempre-productos-eternos-que-tardan-meses-en-ver-la-luz/',
      img: '/img/prensa/scrum-el-adios-para-siempre.jpg'
    },
    { title: I18n.t('press.release02_title'),
      subtitle: 'lanacion.com - 15/Feb/201',
      text: I18n.t('press.release02_text'),
      url: 'https://www.lanacion.com.ar/1664230-el-secreto-de-tus-ojos-a-veces-las-imagenes-ayudan-a-innovar',
      img: '/img/prensa/secreto-de-sus-ojos.jpg'
    },
    { title: I18n.t('press.release01_title'),
      subtitle: 'GESTION.PE - 12/Feb/2014',
      text: I18n.t('press.release01_text'),
      url: 'https://archivo.gestion.pe/empleo-management/scrum-rugby-oficina-2088899',
      img: '/img/prensa/scrum-del-rugby-a-la-oficina.jpg'
    }
  ]
end 

get '/prensa' do
  @active_tab_prensa = 'active'
  meta_tags! title: "#{@base_title} | Prensa"
  # @kleerers = KeventerReader.instance.kleerers session[:locale]
  @news = get_news
  return erb :'news/index', layout: :'layout/layout2022'
end

get '/clientes/equipos-scrum-en-technisys-2015' do
  redirect '/prensa/casos/equipos-scrum-en-technisys-2015', 301 # permanent redirect
end

get '/prensa/casos/equipos-scrum-en-technisys-2015' do
  meta_tags! title: 'Equipos de desarrollo Scrum y Automatización en Technisys'
  meta_tags! description: 'Kleer - Coaching & Training - Equipos de desarrollo Scrum y
 automatización de despliegue de software en Technisys apoyados por Kleer'

  erb :prensa_casos_technisys_2015
end

get '/clientes/equipos-scrum-en-plataforma-10-2015' do
  redirect '/prensa/casos/equipos-scrum-en-plataforma-10-2015', 301 # permanent redirect
end

get '/prensa/casos/equipos-scrum-en-plataforma-10-2015' do
  meta_tags! title: 'Equipos de desarrollo Scrum y Automatización en Plataforma 10'
  meta_tags! description: 'Kleer - Coaching & Training - Equipos de desarrollo Scrum y
 orientación al valor para el negocio en Plataforma 10, apoyados por Kleer'

  erb :prensa_casos_plataforma_10_2015
end

get '/clientes/equipos-scrum-en-suramericana-2015' do
  redirect '/prensa/casos/equipos-scrum-en-suramericana-2015', 301 # permanent redirect
end

get '/prensa/casos/equipos-scrum-en-suramericana-2015' do
  meta_tags! title: 'Paradigma ágil en tecnología y en negocio en Suramericana'
  meta_tags! description: 'Kleer - Coaching & Training - Paradigma ágiles en tecnología y
 en negocio en Suramericana, apoyados por Kleer'

  erb :prensa_casos_suramericana_2015
end

get '/clientes/innovacion-en-marketing-digital-loreal-2016' do
  redirect '/prensa/casos/innovacion-en-marketing-digital-loreal-2016', 301 # permanent redirect
end

get '/prensa/casos/transformacion-agil-ypf-2020' do
  meta_tags! title: 'Así profundizó YPF su camino de transformación ágil'
  meta_tags! description: 'Kleer - Coaching & Training - Creación incremental y colaborativa de
 estrategias digitales facilitada por Kleer'

  erb :prensa_casos_ypf_2020
end

get '/prensa/casos/innovacion-en-marketing-digital-loreal-2016' do
  meta_tags! title: "Innovación en Marketing Digital en L'Oréal"
  meta_tags! description: 'Kleer - Coaching & Training - Creación incremental y colaborativa de
 estrategias digitales facilitada por Kleer'

  erb :prensa_casos_loreal_2016
end

get '/prensa/casos/transformacion-cultural-agil-ti-epm-2018' do
  meta_tags! title: 'EPM se transforma culturalmente'
  meta_tags! description: 'Kleer - Coaching & Training - Cómo acompañamos desde Kleer la transformación ágil de TI en EPM'

  erb :prensa_casos_epm_2018
end

get '/prensa/casos/transformacion-digital-bbva-continental' do
  meta_tags! title: 'Acompañamiento en la transformación digital de BBVA Continental'
  meta_tags! description: 'Kleer - Coaching & Training -Acompañamiento en la transformación digital de BBVA Continental'

  erb :prensa_casos_bbva_2018
end

get '/prensa/casos/falabella-financiero' do
  meta_tags! title: '#ransformación Organizacional en Falabella Financiero'
  meta_tags! description: 'Kleer - Coaching & Training - Transformación Organizacional en Falabella Financiero'

  erb :prensa_casos_falabella_financiero
end

get '/prensa/casos/afp-crecer' do
  meta_tags! title: 'Coaching y transformación ágil en AFP Crecer'
  meta_tags! description: 'Kleer - Coaching & Training - Coaching y transformación ágil en AFP Crecer'

  erb :prensa_casos_afp_crecer
end

get '/prensa/casos/capacitaciones-agiles-endava' do
  meta_tags! title: 'Jornada de capacitaciones ágiles en Endava'
  meta_tags! description: 'Kleer - Coaching & Training - Endava, una empresa internacional que ofrece servicios
 de desarrollo de software con presencia en Latinoamérica, Estados Unidos y Europa, se vio en el desafío de
 mantener la cultura ágil dentro de un contexto de gran crecimiento en poco tiempo.'

  erb :prensa_casos_endava_2018
end
