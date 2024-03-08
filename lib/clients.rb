def client_list
  [
  {name: "Falabella Financiero", img: "/img/clientes/FalabellaFinanciero.webp" },
  {name: "Telefonica", img: "/img/clientes/Telefonica.webp"},
  {name: "Roche", img: "/img/clientes/Roche.webp"},
  {name: "Scotiabank", img: "/img/clientes/Scotiabank.webp"},
  {name: "Sura", img: "/img/clientes/sura.webp"},
  {name: "Cementos Argos", img: "/img/clientes/argos.webp"},
  # {name: "BBVA Continental", img:"/img/clientes/BBVA.webp" },
  # {name: 'Coca-cola', img: '/img/clientes/coca.webp'},
  # {name: 'Disney', img: '/img/clientes/disney.webp'},
  # {name: 'Loreal París', img: '/img/clientes/loreal.webp'},
  {name: "Ecopetrol", img: "/img/clientes/EcoPetrol.webp" },
  {name: "Grupo Nutresa", img: "/img/clientes/grupoNutresa.webp"},
  {name: "Terpel", img: "/img/clientes/terpel.webp"},
  {name: "BCI", img:"/img/clientes/BCi.webp" },
  # {name: "Ecopetrol", img:"/img/clientes/Ecopetrol.png" },


  # {name: 'LATAM', img: '/img/clientes/latam.webp'},
  # {name: "epm", img:"/img/clientes/epm.webp" },
  # {name: "Protección", img:"/img/clientes/proteccion.webp" },
  # {name: "Banco de Occidente", img:"/img/clientes/ban_occidente.webp" },
  # {name: "Banco de Chile", img:"/img/clientes/BancoDeChileB.webp" },
  # # {name: "Banchile", img:"/img/clientes2/" },
  # {name: "Interbank", img:"/img/clientes/interbank.webp" },
  # {name: "BCP", img:"/img/clientes/BCP.webp" },
  # {name: "Interbanking", img:"/img/clientes/interbanking.webp" },
  # {name: "Grupo Galicia", img:"/img/clientes/galicia.webp" },
  # {name: "OSDE", img:"/img/clientes/osde.webp" },
  # # {name: "Cablevisión", img:"/img/clientes/logo-cablevision.png" },
  # {name: "Fibertel", img:"/img/clientes/fibertel.webp" },
  # {name: "YPF" , img:"/img/clientes/YPF.webp" },
  # {name: "Oracle", img:"/img/clientes/oracle.webp" },
  # {name: "Artear", img:"/img/clientes/artear.webp" },
  # # {name: "Telecom", img:"/img/clientes/logo-telecom.jpg" },
  # {name: "Farmacity", img:"/img/clientes/farmacity.webp" },
  # {name: "Cencosud", img:"/img/clientes/cencosud.webp" },
  # {name: "Plataforma 10", img: "/img/clientes/plataforma10.webp" },
  # {name: "Intraway", img: "/img/clientes/intraway.webp" },
  # {name: "Exxon Mobil", img: "/img/clientes/exxo_mobil.webp" },
  # {name: "Technisys", img: "/img/clientes/technisys.webp" },
  # {name: "GlobalLogic", img: "/img/clientes/global_logic.webp" },
  # # {name: "Neoris", img: "/img/clientes/logo-neoris.png" },
  # {name: "Asesuisa", img: "/img/clientes/asesuisa.webp" },
  # {name: "Bancolombia", img: "/img/clientes/bancolombia.webp" },
  # {name: "Colpatria", img: "/img/clientes/colpatria.webp" },
  # {name: "Edenor", img: "/img/clientes/edenor.webp" },
  ]
end

def success_stories(id = nil)
  stories = {
    'afp-crecer' =>{
      title: 'Cómo acompañamos su transformación ágil',
      subtitle: '',
      description: 'Coaching y transformación ágil en <b>AFP Crecer</b>',
      image_url: '/app/img/afp-crecer.jpg',
      sections: [
        {
          heading: 'Necesidad',
          content: 'AFP Crecer, una administradora de fondos de pensiones en El Salvador Cómo acompañamos su transformación ágilcCómo acompañamos su transformación ágilon más de un millón de afiliados, buscaba agilizar sus procesos internos para mejorar el servicio al cliente.'
        },
        {
          heading: 'Búsqueda de la solución',
          content: 'A partir de esta búsqueda surgió la alianza con Kleer, donde se realizó un acompañamiento y capacitaciones para adoptar metodologías ágiles de trabajo con foco en la entrega temprana de valor, comunicación transparente y empoderamiento de equipos.'
        },
        {
          heading: 'Resultado',
          content: 'Gracias a la aplicación de metodologías ágiles de trabajo se pasó de tener proyectos que tardaban un año en salir a la luz a propuestas que en 3 meses ya estaban funcionando. El principal efecto que se pudo visualizar es que al conseguir resultados más rápido, los equipos se motivan naturalmente a seguir mejorando y creando nuevas ideas.',
          videos: [
            {
              url: 'https://www.youtube.com/embed/ouenu5_V9mk',
              title: nil # No specific title or caption was provided
            }
          ]
        }
      ],
    },
    'transformacion-digital-bbva-continental' => {
      title: 'Cómo acompañamos su transformación ágil',
      subtitle: '',
      description: 'Acompañamiento en la transformación digital de <b>BBVA Continental</b>',
      image_url: '/app/img/bbva-clientes.jpg',
      sections: [
        {
          heading: 'Necesidad',
          content: 'BBVA Continental (Perú) estaba atravesando un proceso de transformación digital con tres desafíos claros: <ul><li>Afianzar las prácticas ágiles en el contexto real del banco</li><li>Remover los impedimentos que dificultan el cambio cultural</li><li>Llevar la transformación ágil a más áreas de la empresa.</li></ul>'
        },
        {
          heading: 'Búsqueda de solución',
          content: 'BBVA contactó a Kleer para facilitar el logro de esos objetivos a través de consultoría, mentoring y coaching. El acompañamiento abarcó a equipos y managers para ayudar a incorporar las prácticas ágiles de trabajo y escalarlas.

          Los coaches de Kleer se dedicaron, por un lado, a apoyar a los Scrum Masters, Product Owners y stakeholders en las prácticas ágiles de trabajo y en su escalamiento. El foco estuvo en el desarrollo iterativo e incremental de productos, gestión ágil de proyectos, visual management y técnicas de desarrollo de software de calidad.
          
          Por otro, se realizaron actividades de sensibilización de valores y principios ágiles para potenciar el cambio cultural en otras áreas del banco. Se crearon comunidades de práctica para compartir conocimientos y construir nuevos equipos.
          
          El equipo de coaches se ocupó además de desarrollar agentes de cambio internos, a modo de que la transformación digital continúe con ellos de modo sostenible.'
        },
        {
          heading: 'Resultado',
          content: 'Luego de un año y dos meses de acompañamiento intensivo los equipos de BBVA adoptaron una cultura de trabajo más ágil y transparente. El resultado fue un mayor empoderamiento por parte de los equipos, apoyados por un equipo de Agile Coaches internos formados por Kleer. Y finalmente hubo un considerable aumento en la rapidez de entrega de valor al cliente.

          A continuación compartimos algunos de los testimonios:',
          videos: [
            {
              url: 'https://www.youtube.com/embed/LnRNq8BWbmk',
              title: 'Management y Transformación Digital'
            },
            {
              url: 'https://www.youtube.com/embed/EgbDWWL1ba0',
              title: 'Acompañamiento de Equipos'
            },
            {
              url: 'https://www.youtube.com/embed/RxK46UqLo08',
              title: 'Impacto en el Desarrollo de Proyectos'
            }
          ]
        }
      ],
    },
    'capacitaciones-agiles-endava' => {
      title: 'Cómo acompañamos su transformación ágil',
      subtitle: '',
      description: 'Plan de capacitaciones ágiles en <b>Endava</b>',
      image_url: '/app/img/endava-clientes.jpg',
      sections: [
        {
          heading: 'Necesidades',
          content: 'Endava, una empresa internacional que ofrece servicios de desarrollo de software con presencia en Latinoamérica, Estados Unidos y Europa, se vio en el desafío de mantener la cultura ágil dentro de un contexto de gran crecimiento en poco tiempo.'
        },
        {
          heading: 'Búsqueda de solución',
          content: 'Con el objetivo de transmitir la cultura a las personas que se incorporaban y nivelar conocimiento de metodologías ágiles, se realizó un programa de capacitación de 15 meses en 4 ciudades. Se realizaron talleres de Scrum, XP, DevOps y Comunicación Efectiva.'
        },
        {
          heading: 'Resultado',
          content: 'El aprendizaje vivencial facilitó que las personas se sienten empoderadas para dar devoluciones y proponer cambios, que luego ven implementados. Los entrenamientos altamente interactivos y lúdicos fueron claves para que los integrantes de la compañía salieran motivados a continuar las prácticas ágiles.',
          videos: [
            {
              url: 'https://www.youtube.com/embed/4Fgmm20j8tA',
              title: nil
            }
          ]
        }
      ]
    },
    'transformacion-cultural-agil-ti-epm-2018' => {
      title: 'Cómo acompañamos su transformación ágil',
      subtitle: '',
      description: 'Transformación ágil en <b>EPM</b>',
      image_url: '/app/img/epm-clientes.jpg',
      sections: [
        {
          heading: 'Necesidad',
          content: 'Empresas Públicas Medellín (EPM), una compañía colombiana que brinda servicios de agua, gas y energía a más de 3,5 millones de usuarios, buscaba transformar la forma de trabajo de la Gerencia de TI y sus aliados, hacia una <b>cultura más ágil.</b>'
        },
        {
          heading: 'Búsqueda de solución',
          content: 'EPM contactó a Kleer para ayudarlos a emprender la <b>transformación organizacional</b> de manera ágil y sostenible. Trabajamos con distintos equipos y líderes de la Gerencia de TI a lo largo de <b>5 años</b>, ofreciendo <b>capacitaciones participativas</b> en metodologías ágiles, seguidas de sesiones de <b>coaching</b> a líderes y <b>acompañamiento</b> de equipos en sus tareas diarias, lo cual aceleró la mejora de sus dinámicas y colaboró en el <b>cambio cultural</b>. Parte del acompañamiento incluyó facilitar reuniones, alentar la <b>autonomía</b> de los equipos en el camino de <b>mejora continua</b> y definir <b>indicadores</b> de resultado para conocer el avance de la transformación. También colaboramos con la <b>planificación</b> y algunas <b>tareas técnicas</b>.

          Al día de hoy, seguimos acompañando a EPM como aliados de la Gerencia de TI en diversas líneas de trabajo.'
        },
        {
          heading: 'Resultado',
          content: 'A partir del trabajo de los primeros 6 meses, ya se percibieron <b>mejores tiempos de atención y de entrega de soluciones</b>, incrementando la <b>satisfacción de sus clientes internos</b>. Con el acompañamiento, los equipos asimilaron y pusieron en práctica una <b>cultura de trabajo</b> transparente y empoderadora, que se trasladó al contexto de negocio de cada equipo y a gran parte de la <b>Gerencia de TI</b>, impactando positivamente forma de relacionarse con <b>las áreas de negocio y los proveedores</b> de servicios de desarrollo de software.

          Durante el primer y el segundo año de trabajo, cada vez más equipos mostraron que la cultura ágil ya se reflejaba en sus <b>hábitos</b>, consecuencia de un pilar estratégico del área: la <b>sostenibilidad</b>. También se trabajó en la colaboración entre áreas y los equipos, lo cual disminuyó el <b>trabajo en silos</b> que se veía años atrás.

          Uno de los resultados más visibles es la creación temprana de dos <b>equipos internos de agilistas</b>, agentes de cambio que se encargan de seguir fomentando y manteniendo los principios y las prácticas que el equipo de Kleer les acercó inicialmente.'
        },
        {
          heading: '¿Cómo lo logramos?',
          content: 'Servicios brindados:
          <ul><li>Capacitaciones de Agile y Scrum.</li><li>Capacitaciones de Lean y Kanban.</li><li>Capacitaciones técnicas de Desarrollo Ágil de Software.</li><li>Sesiones de coaching y mentoring a líderes y equipos.</li><li>Facilitación de reuniones (inicio de proyectos y retrospectivas de equipo).</li><li>Rediseño de procesos y estructuras de trabajo.</li>
          <li>Facilitación del PETI: Plan Estratégico de TI a corto, mediano y largo plazo.</li></ul>
          Testimonios de Claudia Toscano Vargas, profesional de la Dirección de Soluciones TI en Empresas Públicas Medellín:',
          videos: [
            {
              url: 'https://www.youtube.com/embed/OQukyDb4tuw',
              title: 'Testimonio de Claudia Toscano Vargas - Parte 1'
            },
            {
              url: 'https://www.youtube.com/embed/VFRxSFGFpIw',
              title: 'Testimonio de Claudia Toscano Vargas - Parte 2'
            }
          ]
        }
      ]
    },
    'falabella-financiero' => { 
      title: 'Cómo acompañamos su transformación ágil',
      subtitle: '',
      description: 'Transformación Organizacional en <b>Falabella Financiero</b>',
      image_url: '/img/prensa/casos/falabella.jpg',
      sections: [
        {
          heading: 'Necesidad',
          content: 'Falabella Financiero, una empresa perteneciente al grupo Falabella y operando en Chile, Perú, Argentina, México y Colombia, se vio en el desafío de escalar y extender la cultura de trabajo de su Digital Factory, donde se desarrollan las aplicaciones financieras corporativas para canales digitales, y que ha crecido exponencialmente desde su creación.'
        },
        {
          heading: 'Búsqueda de solución',
          content: 'La Digital Factory incorporó desde muy temprano una forma de trabajo ágil. Pero luego de un año y medio de crecimiento, era necesario consolidar, escalar y mejorar esta forma de trabajo ágil para acompañar nuevos desafíos de negocio.

          Iniciamos con auto-evaluaciones de agilidad, tanto orientados a equipos como a los líderes. A partir de lo aprendido, comenzamos un proceso de mejora continua de seis meses, con ciclos mensuales con los equipos y agentes de cambios y revisiones trimestrales con los sponsors y gerentes. Las soluciones fueron, a medida que avanzamos, creadas y realizadas cada vez en mayor medida por participantes de la Digital Factory.'
        },
        {
          heading: 'Resultado',
          content: 'Durante el acompañamiento de 6 meses con coaches de Kleer el foco fue formar nuevos equipos que mantengan la cultura ágil, robustecer las relaciones entre equipos, adaptar la comunicación, toma de decisiones y liderazgo a la nueva escala y crear comunidades de práctica para fomentar el desarrollo profesional y el aprendizaje organizacional.

          Algunos resultados destacados:
          
          <ul><li>El tiempo para formar un nuevo equipo pasó de tres a dos meses.</li><li>Se puso en práctica un mecanismo de sincronización para pasajes a producción gestionado por los equipos.</li><li>Cada comunidad de práctica tomó responsabilidad del mantenimiento y evolución de su plataforma y productos.</li><li>Los gerentes delegaron gradualmente varios aspectos de su gestión a las comunidades de prácticas, a los equipos y a un grupo de agentes de cambio.</li></ul>
          Estos son algunos de los testimonios:',
          videos: [
            {
              url: 'https://www.youtube.com/embed/i1Pi3Z28v2A',
              title: 'Testimonio sobre la transformación'
            }
          ]
        }
      ]
    },
    'innovacion-en-marketing-digital-loreal-2016' => {
      title: "Creación incremental y colaborativa de estrategias digitales",
      subtitle: '',
      description: 'Innovación en marketing digital en <b>L\'Oréal</b>',
      image_url: '/app/img/loreal-clientes.jpg',
      sections: [
        {
          heading: 'Necesidad',
          content: "L'Oréal Argentina buscaba adoptar <b>nuevas formas internas de comunicación y trabajo en equipo</b> para transformarse y afrontar los desafíos que le presentan su industria y contexto, incluyendo: <ul><li>4 divisiones de negocio que necesitaban <b>trabajar coordinadamente</b>.</li> <li>La necesidad de una <b>estrategia digital innovadora</b>, centrada en el usuario</li><li>Aumentar la colaboración y la comunicación</li><li>Trabajar efectivamente en <b>proyectos dinámicos</b>.</li></ul> El outcome esperado era diseñar una estrategia digital para cada división que pueda ser implementada en los meses siguientes. El lema de la iniciativa internacional fue <i>“Digital at the Core”</i>."
        },
        {
          heading: 'Búsqueda de la solución',
          content: "Los facilitadores de Kleer diseñaron el formato de cada encuentro junto al equipo de L’Oréal. El proyecto tuvo como sede el campus de Digital House, una coding school ubicada en Belgrano. Aquí se llevaron adelante <b>actividades de co-creación incrementales</b>, con base en la <b>experimentación</b>.

          También se integraron expertos en distintas disciplinas, tales como marketing digital, user experience y campañas digitales. Sus charlas fueron documentadas en vivo por <b>facilitadores gráficos</b> para favorecer la recordación de los temas y causar un mayor impacto."
        },
        {
          heading: 'Resultado',
          content: "Luego de estos encuentros cada una de las divisiones de marketing de L’Oréal ideó y presentó al resto de la organización una estrategia digital validada a partir de experimentos. Los profesionales aprendieron una forma <b>incremental e iterativa</b> de trabajar en equipo, a partir de técnicas de <i>design thinking</i> y desarrollo ágil de productos.",
          videos: [
            {
              url: 'https://www.youtube.com/embed/y6MmcB6TsnQ',
              title: 'Testimonio de Martín Jones, Multibrand Digital Manager de L\'Oréal Argentina'
            }
          ]
        }
      ]
    },
    'equipos-scrum-en-suramericana-2015' => {
      title: 'El camino hacia el paradigma ágil en Suramericana',
      description: 'Paradigma Ágil en <b>Sura</b>',
      image_url: 'https://s3-sa-east-1.amazonaws.com/kleer-images/Kleer-casos-sura1.png',
      sections: [
        {
          heading: 'Necesidad',
          content: 'Suramericana, una compañía de seguros de origen colombiano, líder en Latinoamérica, tomó contacto con el paradigma ágil en un taller de Kleer, en el año 2012. Sus directivos inmediatamente se dieron cuenta de que esta forma de trabajo podría ser el gran diferencial de cara al futuro.'
        },
        {
          heading: 'Búsqueda de solución',
          content: 'Suramericana y Kleer entendieron rápidamente que ambas empresas podían aprender mucho en el camino hacia la agilidad y surgió, naturalmente, un clima de trabajo mutuamente conveniente que se ve plasmado y extendido a otras empresas del grupo económico, hasta el día de hoy.'
        },
        {
          heading: 'Resultado',
          content: 'En el caso de Suramericana, como se ve en los testimonios que encontrarán más abajo, se consitituyó un grupo interno con apoyo continuo del equipo Kleer. Esto es algo que solemos recomendar en las organizaciones a las que acompañamos.

          Este grupo logró transformar la organización en las áreas de tecnología, con resultados asombrosos. Este impacto hizo que las áreas de negocio y corporativas vieran la oportunidad de aplicar las mismas ideas más allá de la tecnología.
          
          Un comentario aparte merecen los rápidos e importantes avances en áreas de negocio y cómo las ideas del paradigma ágil resultan atractivas en cuanto se las ve en funcionamiento. En Suramericana, en varios casos, el cambio hacia el paradigma ágil fluyó desde el área de negocio hacia el área de tecnología, lo que podría considerarse "el camino inverso" hace unos años.',
          videos: [
            {
              url: 'https://www.youtube.com/embed/G6yRoP-9A3s',
              title: 'Testimonio de Carlos Hurtado'
            },
            {
              url: 'https://www.youtube.com/embed/UYehhZxtyWo',
              title: 'Testimonio de Valentina Sierra'
            },
            {
              url: 'https://www.youtube.com/embed/8n20ul5Dyns',
              title: 'Testimonio de Jubel Correa'
            }
          ]
        },
      ]
    },
    'equipos-scrum-en-plataforma-10-2015' => {
      title: 'Valor para el negocio sin escalas en Plataforma 10',
      description: 'Equipos Scrum en <b>Plataforma 10</b>',
      image_url: 'https://s3-sa-east-1.amazonaws.com/kleer-images/Kleer-casos-p10-1.png',
      sections: [
        {
          heading: 'Necesidad',
          content: "Plataforma 10, una empresa líder en el mercado de la venta de pasajes en diversos medios de transporte, encontró que debía maximizar la velocidad de respuesta ante los cambios y desafíos del mercado."
        },
        {
          heading: 'Búsqueda de solución',
          content: "Habiendo dado sus primeros pasos unos años atrás en metodologías ágiles (Scrum) y prácticas de ingeniería (integración continua, automatización, DevOps), vieron que necesitaban apoyo para consolidarlas y trasladarlas hasta las áreas de negocio, por lo que optaron por incorporar servicios de mentoring y coaching de Kleer."
        },
        {
          heading: 'Resultado',
          content: "Desde el comienzo del proyecto se incorporaron activamente las áreas de negocio al proceso de desarrollo, priorizando, debatiendo, detallando y, en muchos casos, descartando tempranamente ideas sobre características a incorporar a los productos.

          La relación entre las áreas de negocio y los equipos de desarrollo cambió para siempre en la organización y la consecución de resultados mejoró en forma sustancial, el tiempo que la compañía se siempre mucho mejor preparada para los grandes desafíos por venir.",
          videos: [
            {
              url: 'https://www.youtube.com/embed/uSzDiuY3P2o',
              title: 'Testimonio de Gustavo Markier - Perspectiva de Negocio'
            },
            {
              url: 'https://www.youtube.com/embed/m4c7WrWralI',
              title: 'Testimonio de Gastón Waisman - Perspectiva de Tecnología'
            }
          ]
        }
      ]
    },
    'equipos-scrum-en-technisys-2015' => {
      title: 'Equipos de desarrollo Scrum en Technisys',
      description: 'Equipos Scrum en <b>Technisys</b>',
      image_url: 'https://s3-sa-east-1.amazonaws.com/kleer-images/Kleer-casos-technisys1.png',
      sections:  [
        {
          title: 'Caso 1: Equipos de desarrollo Scrum en Technisys',
          heading: 'Necesidad',
          content: "Alejandro Raiczyk, a cargo del área de producto de Technisys, nos cuenta como, cuando llegó al área, vio una oportunidad de mejorar en los marcos de trabajo orientándose a las metodologías ágiles."
        },
        {
          heading: 'Búsqueda de solución',
          content: "No disponiendo del know-how dentro de la empresa y no teniendo el tiempo para un proceso extenso de capacitación, optaron por incorporar servicios de mentoring y coaching de Kleer."
        },
        {
          heading: 'Resultado',
          content: "En poco tiempo los equipos comenzaron a trabajar en forma más organizada, con mejor comunicación interna entre los diferentes grupos. En este aspecto, las reuniones de planificación aportaron visibilidad de los objetivos, lo mismo que las reuniones de revisión (en iteraciones de tres semanas). Finalmente destaca la importancia de las reuniones de retrospectiva en el proceso de mejora continua liderado por los propios equipos.",
          videos: [
            {
              url: 'https://www.youtube.com/embed/2oobhTSNQDg',
              title: 'Testimonio de Alejandro Raiczyk - Área de Producto Technisys'
            }
          ]
        },
        {
            title: 'CVaso 2: Automatización de despliegue de software',
            heading: 'Necesidad',
            content: "Nico Páez, especialista en automatización y desarrollo ágil en Kleer, nos cuenta los desafíos del área de producto de Technisys, con un software complejo desarrollado por múltiples equipos."
          },
          {
            heading: 'Búsqueda de solución',
            content: "La necesidad de resolver el problema surgió al mismo tiempo desde los equipos de desarrollo y desde la gerencia decidiendo incorporar, también en este caso, servicios de mentoring y coaching de Kleer."
          },
          {
            heading: 'Resultado',
            content: "Los equipos de desarrollo rápidamente se sumaron a la iniciativa cuyo fin, desde el principio, fue generar el conocimiento en el seno de los equipos, de manera que continuaran con la iniciativa una vez terminado el período de trabajo de Kleer. El proceso de despliegue, que antes estaba en la cabeza de ciertos ingenieros experimentados (que aún así, era muy frágil) paso a estar completamente convertido en código automatizable. El tiempo de despliegue de la solución completa, en la liberación de cada nueva versión, paso de varios días (con una incerteza muy grande) a unas pocas horas.",
            videos: [
              {
                url: 'https://www.youtube.com/embed/9OD_Xp_ZivI',
                title: 'Testimonio de Nico Páez - Especialista en Automatización'
              }
            ]
          },
      ],
      }
  }

  id ? stories[id] : stories
end
