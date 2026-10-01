require 'json'

# SEO / meta / JSON-LD helpers for the Kleer Lab subdomain (lab.kleer.la).
# Ported from the old Rails SeoHelper. Auto-registered as a Sinatra helper
# because the module name ends with "Helper" (see app.rb).
module LabSeoHelper
  LAB_ORG_NAME = 'Kleer Lab'.freeze
  LAB_ORG_URL = 'https://lab.kleer.la'.freeze
  LAB_LOGO_URL = "#{LAB_ORG_URL}/lab/icon.png".freeze
  LAB_PARENT_ORG_URL = 'https://www.kleer.la'.freeze
  LAB_DESCRIPTION = 'Convertimos procesos manuales y repetitivos en aplicaciones hechas ' \
                    'para la operación de cada empresa.'.freeze

  LAB_PAGE_TITLES = {
    home: 'Kleer Lab | Soluciones operativas a medida',
    cases: 'Casos | Kleer Lab'
  }.freeze

  LAB_PAGE_DESCRIPTIONS = {
    # Los resultados de búsqueda cortan alrededor de 155 caracteres: lo que
    # importa —qué hacemos y en cuánto tiempo— entra antes del corte.
    home: 'Convertimos procesos manuales en aplicaciones hechas para tu operación. ' \
          'El primer resultado llega a uso real en semanas, con el código en tus manos.',
    cases: 'Casos reales: procesos manuales resueltos con aplicaciones a medida. Qué había antes, ' \
           'qué se construyó y qué cambió en la operación.'
  }.freeze

  def lab_page_title(scope = :home)
    LAB_PAGE_TITLES[scope] || LAB_PAGE_TITLES[:home]
  end

  def lab_page_description(scope = :home)
    LAB_PAGE_DESCRIPTIONS[scope] || LAB_PAGE_DESCRIPTIONS[:home]
  end

  # Values used by the layout <head>; routes may override via @lab_title etc.
  def lab_title
    @lab_title || lab_page_title(:home)
  end

  def lab_description
    @lab_description || lab_page_description(:home)
  end

  def lab_og_type
    @lab_og_type || 'website'
  end

  def lab_canonical_url
    "#{request.base_url}#{request.path}"
  end

  def lab_og_image
    "#{request.base_url}/lab/og-card.png"
  end

  def lab_case_page_title(kase)
    "#{kase.seo_title} | Caso Kleer Lab"
  end

  def lab_case_page_description(kase)
    if kase.hero_metric
      m = kase.hero_metric
      "#{kase.client_label}: #{m['value']} #{m['label']}. #{kase.industry}. Caso Kleer Lab."
    elsif kase.hero_quote
      "\"#{kase.hero_quote['text']}\". #{kase.industry}. Caso Kleer Lab."
    else
      "#{kase.client_label}. #{kase.industry}. Caso Kleer Lab."
    end
  end
end
