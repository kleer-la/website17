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
    }
    }[id]
end
