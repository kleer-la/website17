class RouterHelper
  attr_accessor :routes, :current_route, :alternate_route, :lang

  ROUTE_TRANSLATIONS = {
    'recursos' => { es: 'recursos', en: 'resources' },
    'resources' => { es: 'recursos', en: 'resources' },
    'blog' => { es: 'blog', en: 'blog' },
    'catalogo' => { es: 'catalogo', en: 'catalog' },
    'catalog' => { es: 'catalogo', en: 'catalog' },
    'servicios' => { es: 'servicios', en: 'services' },
    'services' => { es: 'servicios', en: 'services' }
  }.freeze

  def set_current_route(current_route)
    current_route = current_route[3..] if current_route[0, 3] == '/en' || current_route[0, 3] == '/es'
    @current_route = current_route
  end

  def set_alternate_route(alternate_route)
    @alternate_route = alternate_route
  end

  def get_alternate_route
    if @alternate_route.nil?
      @current_route
    else
      @alternate_route
    end
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

    begin
      # Try to load the resource in the alternate language
      alternate_resource = resource_class.create_one_keventer(slug, alternate_lang)

      # Check if the resource has content in the alternate language
      # If title is empty, the resource doesn't have a translation
      if alternate_resource.title.nil? || alternate_resource.title.strip.empty?
        # No translation available, fallback to index
        @alternate_route = "/#{alternate_base_path}"
      else
        # Translation exists, link to it
        @alternate_route = "/#{alternate_base_path}/#{alternate_resource.slug}"
      end
    rescue StandardError
      # If there's an error loading the resource, fallback to index
      @alternate_route = "/#{alternate_base_path}"
    end
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
