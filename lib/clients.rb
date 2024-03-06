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

def success_stories(id)
  {
    'afp-crecer' =>{
      title: 'Coaching y transformación ágil en AFP Crecer',
      subtitle: '',
      sections: [
        {
          heading: 'Cómo acompañamos su transformación ágil',
          content: 'AFP Crecer, una administradora de fondos de pensiones en El Salvador con más de un millón de afiliados, buscaba agilizar sus procesos internos para mejorar el servicio al cliente.'
        },
        {
          heading: 'Búsqueda de la solución',
          content: 'A partir de esta búsqueda surgió la alianza con Kleer, donde se realizó un acompañamiento y capacitaciones para adoptar metodologías ágiles de trabajo con foco en la entrega temprana de valor, comunicación transparente y empoderamiento de equipos.'
        },
        {
          heading: 'Resultado',
          content: 'Gracias a la aplicación de metodologías ágiles de trabajo se pasó de tener proyectos que tardaban un año en salir a la luz a propuestas que en 3 meses ya estaban funcionando. El principal efecto que se pudo visualizar es que al conseguir resultados más rápido, los equipos se motivan naturalmente a seguir mejorando y creando nuevas ideas.'
        }
      ],
      videos: [
        {
          url: 'https://www.youtube.com/embed/ouenu5_V9mk',
          title: nil # No specific title or caption was provided
        }
      ]
    },
    'transformacion-digital-bbva-continental' => {
      title: 'Acompañamiento en la transformación digital de BBVA Continental',
      subtitle: '',
      sections: [
        {
          heading: 'Cómo acompañamos su transformación ágil',
          content: 'BBVA Continental (Perú) estaba atravesando un proceso de transformación digital con tres desafíos claros: Afianzar las prácticas ágiles en el contexto real del banco, Remover los impedimentos que dificultan el cambio cultural, Llevar la transformación ágil a más áreas de la empresa.'
        },
        {
          heading: 'Búsqueda de solución',
          content: 'BBVA contactó a Kleer para facilitar el logro de esos objetivos a través de consultoría, mentoring y coaching. El acompañamiento abarcó a equipos y managers para ayudar a incorporar las prácticas ágiles de trabajo y escalarlas. Los coaches de Kleer se dedicaron a apoyar a los Scrum Masters, Product Owners y stakeholders, realizaron actividades de sensibilización de valores y principios ágiles, y se ocuparon de desarrollar agentes de cambio internos.'
        },
        {
          heading: 'Resultado',
          content: 'Luego de un año y dos meses de acompañamiento intensivo, los equipos de BBVA adoptaron una cultura de trabajo más ágil y transparente, lo que resultó en un mayor empoderamiento de los equipos y un considerable aumento en la rapidez de entrega de valor al cliente.'
        }
      ],
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
    },
    'capacitaciones-agiles-endava' => {
      title: 'Jornada de capacitaciones ágiles en Endava',
      subtitle: '',
      sections: [
        {
          heading: 'Cómo acompañamos su transformación ágil',
          content: 'Endava, una empresa internacional que ofrece servicios de desarrollo de software con presencia en Latinoamérica, Estados Unidos y Europa, se vio en el desafío de mantener la cultura ágil dentro de un contexto de gran crecimiento en poco tiempo.'
        },
        {
          heading: 'Búsqueda de solución',
          content: 'Con el objetivo de transmitir la cultura a las personas que se incorporaban y nivelar conocimiento de metodologías ágiles, se realizó un programa de capacitación de 15 meses en 4 ciudades. Se realizaron talleres de Scrum, XP, DevOps y Comunicación Efectiva.'
        },
        {
          heading: 'Resultado',
          content: 'El aprendizaje vivencial facilitó que las personas se sienten empoderadas para dar devoluciones y proponer cambios, que luego ven implementados. Los entrenamientos altamente interactivos y lúdicos fueron claves para que los integrantes de la compañía salieran motivados a continuar las prácticas ágiles.'
        }
      ],
      videos: [
        {
          url: 'https://www.youtube.com/embed/4Fgmm20j8tA',
          title: nil
        }
      ]
    },
    'transformacion-cultural-agil-ti-epm-2018' => {
      title: 'La Gerencia de TI EPM se transforma culturalmente',
      subtitle: '',
      sections: [
        {
          heading: 'Cómo acompañamos su transformación ágil',
          content: 'Empresas Públicas Medellín (EPM), una compañía colombiana que brinda servicios de agua, gas y energía a más de 3,5 millones de usuarios, buscaba transformar la forma de trabajo de la Gerencia de TI y sus aliados, hacia una cultura más ágil.'
        },
        {
          heading: 'Búsqueda de solución',
          content: 'EPM contactó a Kleer para ayudarlos a emprender la transformación organizacional de manera ágil y sostenible. Trabajamos con distintos equipos y líderes de la Gerencia de TI a lo largo de 5 años, ofreciendo capacitaciones participativas en metodologías ágiles, seguidas de sesiones de coaching a líderes y acompañamiento de equipos en sus tareas diarias, lo cual aceleró la mejora de sus dinámicas y colaboró en el cambio cultural. Parte del acompañamiento incluyó facilitar reuniones, alentar la autonomía de los equipos y definir indicadores de resultado.'
        },
        {
          heading: 'Resultado',
          content: 'A partir del trabajo de los primeros 6 meses, EPM percibió mejores tiempos de atención y de entrega de soluciones, incrementando la satisfacción de sus clientes internos. Los equipos asimilaron y pusieron en práctica una cultura de trabajo transparente y empoderadora, impactando positivamente en la forma de relacionarse con las áreas de negocio y los proveedores. Se crearon equipos internos de agilistas, agentes de cambio encargados de mantener los principios y prácticas ágiles.'
        },
        {
          heading: '¿Cómo lo logramos?',
          content: 'Ofrecimos capacitaciones de Agile y Scrum, Lean y Kanban, y desarrollo ágil de software, además de sesiones de coaching y mentoring, facilitación de reuniones, rediseño de procesos y estructuras de trabajo, y facilitación del Plan Estratégico de TI.'
        }
      ],
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
    },
    'falabella-financiero' => {
      title: 'Transformación Organizacional en Falabella Financiero',
      subtitle: '',
      sections: [
        {
          heading: 'Cómo acompañamos su transformación ágil',
          content: 'Falabella Financiero, una empresa perteneciente al grupo Falabella y operando en Chile, Perú, Argentina, México y Colombia, se vio en el desafío de escalar y extender la cultura de trabajo de su Digital Factory, donde se desarrollan las aplicaciones financieras corporativas para canales digitales, y que ha crecido exponencialmente desde su creación.'
        },
        {
          heading: 'Búsqueda de solución',
          content: 'La Digital Factory incorporó desde muy temprano una forma de trabajo ágil. Pero luego de un año y medio de crecimiento, era necesario consolidar, escalar y mejorar esta forma de trabajo ágil para acompañar nuevos desafíos de negocio. Iniciamos con auto-evaluaciones de agilidad, tanto orientados a equipos como a los líderes. A partir de lo aprendido, comenzamos un proceso de mejora continua de seis meses, con ciclos mensuales con los equipos y agentes de cambios y revisiones trimestrales con los sponsors y gerentes. Las soluciones fueron, a medida que avanzamos, creadas y realizadas cada vez en mayor medida por participantes de la Digital Factory.'
        },
        {
          heading: 'Resultado',
          content: 'Durante el acompañamiento de 6 meses con coaches de Kleer, el foco fue formar nuevos equipos que mantengan la cultura ágil, robustecer las relaciones entre equipos, adaptar la comunicación, toma de decisiones y liderazgo a la nueva escala y crear comunidades de práctica para fomentar el desarrollo profesional y el aprendizaje organizacional. Destacados resultados incluyen la reducción de tiempo para formar nuevos equipos, implementación de mecanismos de sincronización para pasajes a producción gestionado por los equipos, y delegación de gestión a comunidades de prácticas y equipos.'
        }
      ],
      videos: [
        {
          url: 'https://www.youtube.com/embed/i1Pi3Z28v2A',
          title: 'Testimonio sobre la transformación'
        }
      ]
    },
    'innovacion-en-marketing-digital-loreal-2016' => {
      title: "L'Oréal Argentina",
      subtitle: '',
      sections: [
        {
          heading: 'Creación incremental y colaborativa de estrategias digitales',
          content: "L'Oréal Argentina buscaba adoptar nuevas formas internas de comunicación y trabajo en equipo para transformarse y afrontar los desafíos que le presentan su industria y contexto, incluyendo: 4 divisiones de negocio que necesitaban trabajar coordinadamente, la necesidad de una estrategia digital innovadora, centrada en el usuario, aumentar la colaboración y la comunicación, y trabajar efectivamente en proyectos dinámicos. El outcome esperado era diseñar una estrategia digital para cada división que pueda ser implementada en los meses siguientes. El lema de la iniciativa internacional fue “Digital at the Core”."
        },
        {
          heading: 'Búsqueda de la solución',
          content: "Los facilitadores de Kleer diseñaron el formato de cada encuentro junto al equipo de L’Oréal. El proyecto tuvo como sede el campus de Digital House, una coding school ubicada en Belgrano. Aquí se llevaron adelante actividades de co-creación incrementales, con base en la experimentación. También se integraron expertos en distintas disciplinas, tales como marketing digital, user experience y campañas digitales. Sus charlas fueron documentadas en vivo por facilitadores gráficos para favorecer la recordación de los temas y causar un mayor impacto."
        },
        {
          heading: 'Resultado',
          content: "Luego de estos encuentros cada una de las divisiones de marketing de L’Oréal ideó y presentó al resto de la organización una estrategia digital validada a partir de experimentos. Los profesionales aprendieron una forma incremental e iterativa de trabajar en equipo, a partir de técnicas de design thinking y desarrollo ágil de productos."
        }
      ],
      videos: [
        {
          url: 'https://www.youtube.com/embed/y6MmcB6TsnQ',
          title: 'Testimonio de Martín Jones, Multibrand Digital Manager de L\'Oréal Argentina'
        }
      ]
    }    
    }[id]
end
