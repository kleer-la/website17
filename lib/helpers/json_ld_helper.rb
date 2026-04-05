require 'json'

module JsonLdHelper
  def json_ld_tag(data)
    "<script type=\"application/ld+json\">#{JSON.generate(data)}</script>"
  end

  def organization_json_ld
    {
      '@context' => 'https://schema.org',
      '@type' => 'Organization',
      'name' => 'Kleer',
      'url' => 'https://www.kleer.la',
      'logo' => 'https://www.kleer.la/img/logos/kleer.png',
      'sameAs' => [
        'https://www.linkedin.com/company/kleer',
        'https://twitter.com/klaborativa'
      ],
      'contactPoint' => {
        '@type' => 'ContactPoint',
        'contactType' => 'customer service',
        'url' => 'https://www.kleer.la'
      }
    }
  end

  def website_json_ld
    {
      '@context' => 'https://schema.org',
      '@type' => 'WebSite',
      'name' => 'Kleer',
      'url' => 'https://www.kleer.la',
      'inLanguage' => [session[:locale] == 'en' ? 'en' : 'es']
    }
  end

  def article_json_ld(article)
    data = {
      '@context' => 'https://schema.org',
      '@type' => 'Article',
      'headline' => article.title,
      'description' => article.description,
      'url' => "https://www.kleer.la/#{article.lang}/blog/#{article.slug}",
      'inLanguage' => article.lang || 'es',
      'publisher' => {
        '@type' => 'Organization',
        'name' => 'Kleer',
        'logo' => {
          '@type' => 'ImageObject',
          'url' => 'https://www.kleer.la/img/logos/kleer.png'
        }
      }
    }
    data['image'] = article.cover if article.cover && !article.cover.empty?
    data['datePublished'] = article.created_at if article.created_at.to_s != ''
    data['dateModified'] = article.substantive_change_at if article.substantive_change_at.to_s != ''

    if article.trainers_list && !article.trainers_list.empty?
      data['author'] = article.trainers_list.map do |trainer|
        { '@type' => 'Person', 'name' => trainer.name }
      end
    else
      data['author'] = { '@type' => 'Organization', 'name' => 'Kleer' }
    end

    data
  end

  def service_json_ld(service, service_area)
    {
      '@context' => 'https://schema.org',
      '@type' => 'Service',
      'name' => service.name,
      'description' => service.seo_description || service.subtitle,
      'provider' => {
        '@type' => 'Organization',
        'name' => 'Kleer'
      },
      'category' => service_area.name
    }
  end

  def course_json_ld(event_type)
    data = {
      '@context' => 'https://schema.org',
      '@type' => 'Course',
      'name' => event_type.name,
      'description' => event_type.elevator_pitch,
      'provider' => {
        '@type' => 'Organization',
        'name' => 'Kleer',
        'url' => 'https://www.kleer.la'
      },
      'inLanguage' => event_type.lang || 'es'
    }
    data['image'] = event_type.cover if event_type.cover && !event_type.cover.to_s.empty?
    data
  end

  def resource_json_ld(resource)
    lang = resource.lang.to_s
    lang = 'es' if lang.empty?
    path_prefix = lang == 'en' ? 'resources' : 'recursos'

    data = {
      '@context' => 'https://schema.org',
      '@type' => 'CreativeWork',
      'name' => resource.title,
      'description' => resource.seo_description,
      'url' => "https://www.kleer.la/#{lang}/#{path_prefix}/#{resource.slug}",
      'inLanguage' => lang,
      'publisher' => {
        '@type' => 'Organization',
        'name' => 'Kleer'
      }
    }
    data['image'] = resource.cover if resource.cover && !resource.cover.to_s.empty?

    if resource.author_trainers && !resource.author_trainers.empty?
      data['author'] = resource.author_trainers.map do |trainer|
        { '@type' => 'Person', 'name' => trainer.name }
      end
    end

    data
  end
end
