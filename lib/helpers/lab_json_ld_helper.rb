require 'json'
require './lib/helpers/lab_seo_helper'
require './lib/helpers/json_ld_helper'

# JSON-LD for the Kleer Lab subdomain: who it is, its site, the service its
# home presents and each case as an article (#442). Auto-registered as a
# Sinatra helper because the module name ends with "Helper" (see app.rb).
module LabJsonLdHelper
  include LabSeoHelper

  def lab_json_ld_organization
    { '@context' => 'https://schema.org', '@type' => 'Organization', 'name' => LAB_ORG_NAME, 'url' => LAB_ORG_URL,
      'logo' => LAB_LOGO_URL, 'description' => LAB_DESCRIPTION, 'areaServed' => lab_area_served,
      'contactPoint' => { '@type' => 'ContactPoint', 'contactType' => 'sales', 'url' => "#{LAB_ORG_URL}/contacto" },
      'parentOrganization' => lab_parent_organization }
  end

  def lab_parent_organization = { '@type' => 'Organization', 'name' => 'Kleer', 'url' => LAB_PARENT_ORG_URL }

  # Where Kleer Lab works: Kleer's own area (config/organization.yml), in Spanish.
  def lab_area_served
    JsonLdHelper::ORGANIZATION['area_served'].map { |area| { '@type' => area['type'], 'name' => area['name']['es'] } }
  end

  def lab_json_ld_website
    { '@context' => 'https://schema.org', '@type' => 'WebSite', 'name' => LAB_ORG_NAME, 'url' => "#{LAB_ORG_URL}/",
      'inLanguage' => 'es', 'publisher' => { '@type' => 'Organization', 'name' => LAB_ORG_NAME } }
  end

  # The home presents a service business: what it does and where (#442).
  def lab_json_ld_professional_service
    { '@context' => 'https://schema.org', '@type' => 'ProfessionalService', 'name' => LAB_ORG_NAME,
      'url' => "#{LAB_ORG_URL}/", 'image' => "#{LAB_ORG_URL}/lab/og-card.png", 'description' => LAB_DESCRIPTION,
      'areaServed' => lab_area_served, 'parentOrganization' => lab_parent_organization }
  end

  def lab_json_ld_for_case(kase)
    keywords = [kase.industry]
    keywords << kase.hero_metric['value'] if kase.hero_metric

    lab_org = { '@type' => 'Organization', 'name' => LAB_ORG_NAME, 'url' => LAB_ORG_URL }
    payload = { '@context' => 'https://schema.org', '@type' => 'Article', 'articleSection' => 'Case study',
                'headline' => kase.title, 'keywords' => keywords.compact.join(', '),
                'author' => lab_org, 'publisher' => lab_org }.merge(lab_case_page_fields(kase))
    payload['datePublished'] = kase.date_published if kase.date_published
    payload['dateModified'] = kase.date_modified if kase.date_modified
    payload
  end

  # Its page, the client it is about, and an image: the case's first picture,
  # or the Lab card when it has none.
  def lab_case_page_fields(kase)
    picture = kase.gallery.filter_map { |item| item['src'] }.first
    { 'mainEntityOfPage' => "#{LAB_ORG_URL}/casos/#{kase.slug}",
      'image' => picture ? "#{LAB_ORG_URL}/lab/cases/#{kase.slug}/#{picture}" : "#{LAB_ORG_URL}/lab/og-card.png",
      'about' => { '@type' => 'Organization', 'name' => kase.client_name,
                   'description' => kase.client_descriptor }.compact }
  end

  def lab_json_ld_breadcrumb_for_case(kase)
    {
      '@context' => 'https://schema.org',
      '@type' => 'BreadcrumbList',
      'itemListElement' => [
        { '@type' => 'ListItem', 'position' => 1, 'name' => 'Inicio', 'item' => "#{LAB_ORG_URL}/" },
        { '@type' => 'ListItem', 'position' => 2, 'name' => 'Casos', 'item' => "#{LAB_ORG_URL}/casos" },
        { '@type' => 'ListItem', 'position' => 3, 'name' => kase.title,
          'item' => "#{LAB_ORG_URL}/casos/#{kase.slug}" }
      ]
    }
  end

  def lab_render_json_ld(hash)
    json = hash.to_json.gsub('</', '<\/')
    %(<script type="application/ld+json">#{json}</script>)
  end
end
