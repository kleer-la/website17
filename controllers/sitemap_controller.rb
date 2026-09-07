require 'nokogiri'

BASE_URL = 'https://www.kleer.la'

# Each section names the languages it has, and both its URLs and its alternates
# follow from that. Novedades and Podcasts have only Spanish: the records behind
# them carry no translation, so /en/news and /en/podcasts answered 200 with the
# Spanish copy — listed here, they spent crawl on a page that speaks the wrong
# language and offered it as the English version of one that reads fine.
# The Agenda is Spanish-only by decision: there are no open editions to list,
# and it loaded them without filtering by language, so /en/schedule announced
# Spanish courses.
STATIC_PAGES = {
  '/' => { es: '/', en: '/' },
  '/blog' => { es: '/blog', en: '/blog' },
  '/servicios' => { es: '/servicios', en: '/services' },
  '/catalogo' => { es: '/catalogo', en: '/catalog' },
  '/agenda' => { es: '/agenda' },
  '/recursos' => { es: '/recursos', en: '/resources' },
  '/somos' => { es: '/somos', en: '/about_us' },
  '/clientes' => { es: '/clientes', en: '/clients' },
  '/podcasts' => { es: '/podcasts' },
  '/novedades' => { es: '/novedades' }
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

def add_dynamic_urls(_xml, label)
  yield
rescue StandardError => e
  logger.warn "Sitemap: could not load #{label}: #{e.message}"
end

get '/sitemap.xml' do
  return handle_lab_sitemap if @is_lab

  content_type 'application/xml'

  builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
    xml.urlset(xmlns: 'http://www.sitemaps.org/schemas/sitemap/0.9',
               'xmlns:xhtml' => 'http://www.w3.org/1999/xhtml') do
      STATIC_PAGES.each do |key, paths|
        paths.each_key do |lang|
          xml.url do
            xml.loc "#{BASE_URL}/#{lang}#{paths[lang]}"
            xml.changefreq 'weekly'
            xml.priority(key == '/' ? '1.0' : '0.8')
            paths.each do |alt_lang, alt_path|
              xml['xhtml'].link(rel: 'alternate', hreflang: alt_lang.to_s,
                                href: "#{BASE_URL}/#{alt_lang}#{alt_path}")
            end
          end
        end
      end

      add_dynamic_urls(xml, 'articles') do
        Article.create_list_keventer(true).each do |article|
          next unless article.published
          # The page itself answers noindex, so listing it here asks for a
          # crawl that can only end in "excluded by noindex tag".
          next if article.noindex

          lang = article.lang || 'es'
          # `''.split('T').first` is nil, not '', and `nil.empty?` raised — inside
          # add_dynamic_urls, which catches and logs, so one article with no
          # date silently took every article out of the sitemap.
          lastmod = article.substantive_change_at.to_s.split('T').first.to_s
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
          # A course with an external site answers 301 to it. A sitemap lists the
          # pages worth indexing, not the ones that send crawlers elsewhere.
          next if et.external_site_url.to_s != ''
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
