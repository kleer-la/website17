class RouterHelper
  attr_accessor :routes, :current_route, :alternate_route, :lang

  ROUTE_TRANSLATIONS = {
    'recursos' => { es: 'recursos', en: 'resources' },
    'resources' => { es: 'recursos', en: 'resources' },
    'blog' => { es: 'blog', en: 'blog' },
    'catalogo' => { es: 'catalogo', en: 'catalog' },
    'catalog' => { es: 'catalogo', en: 'catalog' },
    'services' => { es: 'services', en: 'services' }
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

  def self.instance
    @instance ||= new
  end
end
