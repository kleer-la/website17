require './lib/json_api'
require './lib/services/keventer_api'

class Resource
  @next_null = false
  @resource_null = nil

  def self.create_one_null(res, opt = {})
    @next_null = opt[:next_null] == true
    @resource_null = Resource.new(res, res['lang'] || :es)
  end

  def self.create_one_keventer(slug)
    if @next_null
      @next_null = false
      raise ResourceNotFoundError.new(slug) unless @resource_null.slug == slug

      return @resource_null
    end

    sanitized_slug = slug.unicode_normalize(:nfd).gsub(/\p{M}/, '')
    api_resp = JsonAPI.new(KeventerAPI.resource_url(sanitized_slug))
    raise ResourceNotFoundError.new(slug) unless api_resp.ok?

    Resource.new(api_resp.doc, api_resp.doc['lang'] || :es)
  end

  def self.create_list_null(data)
    @next_null = true
    @objects_null = Resource.load_list(data)
  end

  def self.create_list_keventer
    if @next_null
      @next_null = false
      return @objects_null
    end
    api_resp = JsonAPI.new(KeventerAPI.resources_url)
    raise :NotFound unless api_resp.ok?

    Resource.load_list(api_resp.doc)
  end
  LOCALIZED_FIELDS = %w[
    title
    description
    cover
    landing
    getit
    buyit
    share_link
    share_text
    tags
    comments
    preview
    long_description
  ].freeze
  attr_accessor :id, :format, :slug, :lang,
                :authors, :translators, :illustrators, # String representations for backward compatibility
                :authors_list, :translators_list, :illustrators_list, # Original name lists
                :author_trainers, :translator_trainers, :illustrator_trainers, # New Trainer objects
                :fb_share, :tw_share, :li_share, :kleer_share_url,
                :title, :description, :cover, :landing, :getit, :buyit, :share_link, :share_text, :tags, :comments,
                :preview, :long_description, :recommended

  def initialize(doc, lang)
    @id = doc['id']
    @format = doc['format']
    @slug = doc['slug']
    @lang = lang

    init_localized_fields(doc)

    init_urls

    # Convert contributors to Trainer objects
    @author_trainers = load_contributors_as_trainers(doc, 'authors')
    @translator_trainers = load_contributors_as_trainers(doc, 'translators')
    @illustrator_trainers = load_contributors_as_trainers(doc, 'illustrators')

    # Keep original string representations for backward compatibility
    @authors = format_contributors_as_string(@author_trainers)
    @translators = format_contributors_as_string(@translator_trainers)

    # Keep original name lists
    @authors_list = doc['authors']&.map { |e| e['name'] } || []
    @translators_list = doc['translators']&.map { |e| e['name'] } || []
    @illustrators_list = doc['illustrators']&.map { |e| e['name'] } || []

    init_dates(doc)
    init_recommended(doc)
    # "categories_id": null,
  end

  def show_one_trainer(trainer_data)
    trainer = trainer_data['name']
    landing = trainer_data['landing']
    trainer = "<a href=\"#{landing}\">#{trainer}</a>" unless landing.to_s == ''
    trainer
  end

  def trainers_with_role
    author_trainers + translator_trainers + illustrator_trainers
  end

  def self.load_list(doc)
    doc.each_with_object([]) do |data, ac|
      (ac << Resource.new(data, :es)) unless data['title_es'] == ''
      (ac << Resource.new(data, :en)) unless data['title_en'] == ''
      ac
    end
  end

  private

  def init_trainers(doc, role)
    return nil if doc[role].nil?

    list = (doc[role]&.reduce([]) { |ac, t| ac << show_one_trainer(t) }
           )
    return if list == []

    list.join(', ')
  end

  def init_dates(doc)
    @created_at = doc['created_at'] || ''
    @updated_at = doc['updated_at'] || ''
  end

  def init_localized_fields(doc)
    LOCALIZED_FIELDS.each do |field|
      instance_variable_set("@#{field}", doc["#{field}_#{@lang}"] || '')
    end
  end

  def load_contributors_as_trainers(doc, role)
    contributors = doc[role]
    return [] if contributors.nil? || contributors.empty?

    contributors.map do |contributor|
      trainer = Trainer.new
      trainer.load_from_json(contributor)
      trainer.role = role
      trainer
    end
  end

  def format_contributors_as_string(contributors)
    return nil if contributors.nil? || contributors.empty?

    contributors.map do |contributor|
      landing = contributor.landing
      name = contributor.name
      landing.to_s.empty? ? name : "<a href=\"#{landing}\">#{name}</a>"
    end.join(', ')
  end

  def init_urls
    @kleer_share_url = "https://www.kleer.la/#{lang}/recursos##{@slug}"

    share_url = @kleer_share_url
    share_url = @share_link unless @share_link.to_s == ''

    @fb_share = URI.encode_www_form(
      u: share_url,
      quote: @share_text,
      hashtags: @tags
    )

    @tw_share = URI.encode_www_form(
      text: "#{@share_text} #{share_url}",
      hashtags: @tags
    )
    # https://www.linkedin.com/sharing/share-offsite/?url=[your URL]&summary=[your post text]&source=[your source]&hashtags=[your hashtags separated by commas]

    @li_share = URI.encode_www_form(
      url: share_url,
      summary: "#{@share_text} #{share_url}",
      source: @kleer_share_url,
      hashtags: @tags
    )
  end

  def init_recommended(doc)
    @recommended = Recommended.create_list(doc['recommended'])
  end
end

class ResourceNotFoundError < StandardError
  def initialize(slug)
    super("Resource with slug '#{slug}' not found")
  end
end
