require 'nokogiri'

BASE_URL = 'https://www.kleer.la'

STATIC_PAGES = {
  '/' => { es: '/', en: '/' },
  '/blog' => { es: '/blog', en: '/blog' },
  '/servicios' => { es: '/servicios', en: '/services' },
  '/catalogo' => { es: '/catalogo', en: '/catalog' },
  '/agenda' => { es: '/agenda', en: '/schedule' },
  '/recursos' => { es: '/recursos', en: '/resources' },
  '/somos' => { es: '/somos', en: '/about_us' },
  '/clientes' => { es: '/clientes', en: '/clients' },
  '/podcasts' => { es: '/podcasts', en: '/podcasts' },
  '/novedades' => { es: '/novedades', en: '/news' }
}.freeze

def add_url(xml, path:, changefreq: 'weekly', priority: '0.7', lastmod: nil, hreflang: nil)
  xml.url do
    xml.loc "#{BASE_URL}#{path}"
    xml.lastmod lastmod if lastmod
    xml.changefreq changefreq
    xml.priority priority
    if hreflang
      hreflang.each do |lang, href|
        xml['xhtml'].link(rel: 'alternate', hreflang: lang.to_s, href: "#{BASE_URL}#{href}")
      end
    end
  end
end

def add_dynamic_urls(xml, label)
  yield
rescue StandardError => e
  logger.warn "Sitemap: could not load #{label}: #{e.message}"
end

get '/sitemap.xml' do
  content_type 'application/xml'

  builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
    xml.urlset(xmlns: 'http://www.sitemaps.org/schemas/sitemap/0.9',
               'xmlns:xhtml' => 'http://www.w3.org/1999/xhtml') do
      STATIC_PAGES.each do |key, paths|
        %i[es en].each do |lang|
          xml.url do
            xml.loc "#{BASE_URL}/#{lang}#{paths[lang]}"
            xml.changefreq 'weekly'
            xml.priority(key == '/' ? '1.0' : '0.8')
            %i[es en].each do |alt_lang|
              xml['xhtml'].link(rel: 'alternate', hreflang: alt_lang.to_s,
                                href: "#{BASE_URL}/#{alt_lang}#{paths[alt_lang]}")
            end
          end
        end
      end

      add_dynamic_urls(xml, 'articles') do
        Article.create_list_keventer(true).each do |article|
          next unless article.published

          lang = article.lang || 'es'
          lastmod = article.substantive_change_at.to_s.split('T').first
          article_path = "/#{lang}/blog/#{article.slug}"
          add_url(xml, path: article_path,
                       changefreq: 'monthly', priority: '0.6',
                       lastmod: lastmod.empty? ? nil : lastmod,
                       hreflang: { lang => article_path })
        end
      end

      add_dynamic_urls(xml, 'service areas') do
        %w[es en].each do |lang|
          areas = ServiceAreaV3.try_create_list_keventer.select { |a| a.lang == lang }
          path_prefix = lang == 'es' ? 'servicios' : 'services'

          areas.each do |area|
            next if area.is_training_program

            add_url(xml, path: "/#{lang}/#{path_prefix}/#{area.slug}")
            area.services.each do |service|
              add_url(xml, path: "/#{lang}/#{path_prefix}/#{area.slug}/#{service.slug}")
            end
          end
        end
      end

      add_dynamic_urls(xml, 'catalog') do
        seen_slugs = Set.new
        (Catalog.create_keventer_json || []).each do |event|
          et = event.event_type
          next if et.nil? || et.deleted || et.noindex
          next if et.slug.nil? || et.slug.empty?
          next unless seen_slugs.add?("#{et.lang}-#{et.slug}")

          lang = et.lang || 'es'
          path_prefix = lang == 'en' ? 'courses' : 'cursos'
          course_path = "/#{lang}/#{path_prefix}/#{et.slug}"
          add_url(xml, path: course_path, priority: '0.6',
                       hreflang: { lang => course_path })
        end
      end

      add_dynamic_urls(xml, 'resources') do
        Resource.create_list_keventer.each do |resource|
          next if resource.title.to_s.strip.empty?

          lang = resource.lang.to_s
          lang = 'es' if lang.empty?
          path_prefix = lang == 'en' ? 'resources' : 'recursos'
          resource_path = "/#{lang}/#{path_prefix}/#{resource.slug}"
          lastmod = resource.updated_at.to_s.split('T').first
          add_url(xml, path: resource_path,
                       changefreq: 'monthly', priority: '0.6',
                       lastmod: lastmod.to_s.empty? ? nil : lastmod,
                       hreflang: { lang => resource_path })
        end
      end

      add_dynamic_urls(xml, 'training programs') do
        %w[es en].each do |lang|
          programs = ServiceAreaV3.try_create_list_keventer(programs: true).select { |a| a.lang == lang }
          path_prefix = lang == 'es' ? 'formacion' : 'training'

          programs.each do |program|
            add_url(xml, path: "/#{lang}/#{path_prefix}/#{program.slug}")
          end
        end
      end
    end
  end

  builder.to_xml
end
