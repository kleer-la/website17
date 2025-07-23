require './lib/json_api'
require './lib/services/keventer_api'
require './lib/helpers/app_helper'
require './lib/models/recommended'
require './lib/trainer'

class Resource
  @next_null = false
  @resource_null = nil

  def self.create_one_null(res, locale, opt = {})
    @next_null = opt[:next_null] == true
    @resource_null = Resource.new(res, locale || 'es')
  end

  def self.create_one_keventer(slug, locale = 'es')
    if @next_null
      @next_null = false
      raise ResourceNotFoundError.new(slug) unless @resource_null.slug == slug

      return @resource_null
    end

    sanitized_slug = slug.unicode_normalize(:nfd).gsub(/\p{M}/, '')
    api_url = "#{KeventerAPI.resource_url(sanitized_slug)}?lang=#{locale}"
    
    begin
      api_resp = JsonAPI.new(api_url)
      raise ResourceNotFoundError.new(slug) unless api_resp.ok?

      Resource.new(api_resp.doc, locale)
    rescue StandardError => e
      unless ENV['RACK_ENV'] == 'test'
        puts "Error creating resource for slug '#{slug}': #{e.message}"
        puts "URL: #{api_url}"
        puts "Backtrace: #{e.backtrace.first(5).join("\n")}"
      end
      raise e
    end
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
    tabtitle
    seo_description
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
                :authors, :translators, :illustrators,
                :downloadable, :assessment_id,
                :authors_list, :translators_list, :illustrators_list,
                :author_trainers, :translator_trainers, :illustrator_trainers,
                :fb_share, :tw_share, :li_share, :kleer_share_url, :recommended,
                *LOCALIZED_FIELDS

  def initialize(doc, lang)
    @id = doc['id']
    @format = doc['format']
    @slug = doc['slug']
    @lang = lang
    @downloadable = AppHelper::boolean_value(doc['downloadable'])
    @assessment_id = doc.dig('assessment', 'id')

    init_localized_fields(doc)
    init_urls
    init_contributors(doc)
    init_dates(doc)
    init_recommended(doc).filter! { |rec| rec.lang == lang }
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

  def also_download(max)
    # puts "Resource#also_download:downloadable=#{@downloadable}, #{@recommended.inspect}"
    return [] if !@downloadable
    @recommended.select { |rec| rec.type == 'resource' && rec.downloadable}.first(max)
    @recommended.select { |rec| rec.type == 'resource' && rec.downloadable}
  end

  def recommended_not_downloads
    downloadable_slugs = also_download(3).map(&:slug)
    @recommended.reject { |rec| downloadable_slugs.include?(rec.slug) }
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
      value = doc["#{field}_#{@lang}"] || ''
      instance_variable_set("@#{field}", value)
    end
    @tabtitle = @title if @tabtitle.to_s == ''
    @seo_description = @description if @seo_description.to_s == ''

    @seo_description = @seo_description[0..156] + '...' if @seo_description.length > 160
  end

  def load_contributors_as_trainers(doc, role)
    contributors = doc[role]
    return [] if contributors.nil? || contributors.empty?

    contributors.map do |contributor|
      trainer = Trainer.new(@lang)
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
    @recommended = Recommended.create_list(doc['recommended'], @lang).select { |rec| rec.title.to_s.strip != '' }
  end

  def init_contributors(doc)
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
  end
end

class ResourceNotFoundError < StandardError
  def initialize(slug)
    super("Resource with slug '#{slug}' not found")
  end
end
