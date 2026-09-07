class RouterHelper
  attr_accessor :routes, :current_route, :alternate_route, :lang

  ROUTE_TRANSLATIONS = {
    'recursos' => { es: 'recursos', en: 'resources' },
    'resources' => { es: 'recursos', en: 'resources' },
    'blog' => { es: 'blog', en: 'blog' },
    'catalogo' => { es: 'catalogo', en: 'catalog' },
    'catalog' => { es: 'catalogo', en: 'catalog' },
    'servicios' => { es: 'servicios', en: 'services' },
    'services' => { es: 'servicios', en: 'services' },
    'formacion' => { es: 'formacion', en: 'training' },
    'training' => { es: 'formacion', en: 'training' },
    'agenda' => { es: 'agenda', en: 'schedule' },
    'schedule' => { es: 'agenda', en: 'schedule' },
    'somos' => { es: 'somos', en: 'about_us' },
    'about_us' => { es: 'somos', en: 'about_us' },
    'novedades' => { es: 'novedades', en: 'news' },
    'news' => { es: 'novedades', en: 'news' },
    'clientes' => { es: 'clientes', en: 'clients' },
    'clients' => { es: 'clientes', en: 'clients' }
  }.freeze

  def set_current_route(current_route)
    current_route = current_route[3..] if ['/en', '/es'].include?(current_route[0, 3])
    @current_route = current_route
  end

  def set_alternate_route(alternate_route)
    @alternate_route = alternate_route
  end

  # Where the language switcher points. Without an alternate spelled out by a
  # controller it used to offer the current path with the prefix swapped —
  # /en/recursos, which redirects — so the section gets translated here for the
  # same reason the hreflang does.
  def get_alternate_route
    return @alternate_route unless @alternate_route.nil?

    RouterHelper.translate_first_segment(@current_route, alternate_lang)
  end

  def alternate_lang
    @lang.to_s == 'en' ? 'es' : 'en'
  end

  # Sets alternate route for a resource with fallback to index if translation doesn't exist
  # @param base_path [String] base path (e.g., 'recursos', 'resources', 'blog')
  # @param slug [String] the slug of the current resource
  # @param current_lang [String] current language ('es' or 'en')
  # @param resource_class [Class] the model class (e.g., Resource, Article)
  def set_alternate_route_with_fallback(base_path, slug, current_lang, resource_class)
    alternate_lang = current_lang == 'es' ? 'en' : 'es'
    route_config = ROUTE_TRANSLATIONS[base_path]

    return unless route_config

    alternate_base_path = route_config[alternate_lang.to_sym]
    alternate_slug = translated_slug(resource_class, slug, alternate_lang)

    # The switcher goes to the translation when there is one, and to the index
    # when there is not — landing on the section beats landing on nothing.
    @alternate_route = if alternate_slug
                         "/#{alternate_base_path}/#{alternate_slug}"
                       else
                         "/#{alternate_base_path}"
                       end
    alternate_slug
  end

  # The slug this content has in the other language, or nil when it has none.
  # An empty title is how the API says "not translated", and the caller needs
  # the difference: it decides between declaring one language and declaring two.
  def translated_slug(resource_class, slug, lang)
    translated = resource_class.create_one_keventer(slug, lang)
    return nil if translated.title.to_s.strip.empty?

    translated.slug
  rescue StandardError
    nil
  end

  # Translates a path segment to the appropriate language
  # @param base_path [String] the path segment to translate (e.g., 'recursos', 'resources', 'servicios')
  # @param locale [String, Symbol] the target locale ('es' or 'en')
  # @return [String] the translated path segment, or the original if no translation exists
  # @example
  #   RouterHelper.translate_path('recursos', 'en') # => 'resources'
  #   RouterHelper.translate_path('resources', 'es') # => 'recursos'
  #   RouterHelper.translate_path('blog', 'en') # => 'blog' (same in both languages)
  def self.translate_path(base_path, locale)
    route_config = ROUTE_TRANSLATIONS[base_path]
    return base_path unless route_config

    route_config[locale.to_sym] || base_path
  end

  # The same path with its section translated, for the language alternates that
  # no controller spells out. Swapping only the prefix names /en/recursos, which
  # redirects, and an alternate pointing at a redirect is a pair Google never
  # confirms. A section the table does not know keeps the path it has: /privacy
  # and /podcasts are the same URL in both languages.
  # @example
  #   RouterHelper.translate_first_segment('/recursos/dod-kards', 'en')
  #   # => '/resources/dod-kards'
  def self.translate_first_segment(path, locale)
    head, section, rest = path.to_s.split('/', 3)
    return path if head.to_s != '' || section.to_s.empty?

    ['', translate_path(section, locale), rest].compact.join('/')
  end

  # The language a path names through its first segment, or nil when it starts
  # with something the table does not know — which is how /events, /assessment,
  # /robots.txt and the /es and /en prefixes themselves stay out of it.
  # @example
  #   RouterHelper.language_of_path('/services')  # => 'en'
  #   RouterHelper.language_of_path('/servicios') # => 'es'
  #   RouterHelper.language_of_path('/es/servicios') # => nil
  def self.language_of_path(path)
    head, section, = path.to_s.split('/', 3)
    return nil unless head.to_s.empty?

    config = ROUTE_TRANSLATIONS[section]
    return nil if config.nil?

    # A section that reads the same in both languages has no language to name;
    # Spanish is the site's default and the canonical those pages already give.
    config[:en] == section && config[:es] != section ? 'en' : 'es'
  end

  # Returns the alternate path for a given path and current language
  # @param base_path [String] the path segment (e.g., 'recursos', 'catalogo', 'agenda')
  # @param current_lang [String, Symbol] the current language ('es' or 'en')
  # @return [String] the path in the alternate language with leading slash
  # @example
  #   RouterHelper.alternate_path('recursos', 'es') # => '/resources'
  #   RouterHelper.alternate_path('catalog', 'en') # => '/catalogo'
  #   RouterHelper.alternate_path('agenda', 'es') # => '/schedule'
  def self.alternate_path(base_path, current_lang)
    alternate_lang = current_lang.to_s == 'es' ? 'en' : 'es'
    '/' + translate_path(base_path, alternate_lang)
  end

  # The alternates for a section whose slug differs per language, ready for
  # Metatags. Without them the alternate is the current path with the prefix
  # swapped — /en/somos, which redirects to /en/about_us, and an alternate that
  # points at a redirect is a pair Google never confirms.
  # @example
  #   RouterHelper.alternate_paths('somos') # => { es: '/somos', en: '/about_us' }
  def self.alternate_paths(base_path)
    { es: "/#{translate_path(base_path, 'es')}", en: "/#{translate_path(base_path, 'en')}" }
  end

  # Detects if a path has mixed language (locale prefix doesn't match path segments)
  # and returns the corrected path if needed
  # @param locale [String] the locale from the URL prefix ('es' or 'en')
  # @param path [String] the path after the locale prefix
  # @return [String, nil] the corrected path if mixed language detected, nil otherwise
  def self.detect_mixed_language(locale, path)
    return nil unless %w[es en].include?(locale)

    # Extract the first path segment (e.g., 'servicios' from '/servicios/coaching')
    path_parts = path.split('/').reject(&:empty?)
    return nil if path_parts.empty?

    first_segment = path_parts.first
    route_config = ROUTE_TRANSLATIONS[first_segment]
    return nil unless route_config

    # Get the expected segment for this locale
    expected_segment = route_config[locale.to_sym]

    # If the first segment doesn't match the expected one for this locale, correct it
    if first_segment != expected_segment
      # Replace the first segment with the correct one
      path_parts[0] = expected_segment
      "/#{path_parts.join('/')}"
    else
      nil # No correction needed
    end
  end

  def self.instance
    @instance ||= new
  end
end
