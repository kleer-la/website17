require './lib/helpers/app_helper'
require './lib/image_url_helper'

class Recommended
  attr_reader :title, :subtitle, :slug, :type, :level, :downloadable, :lang, :is_training_program

  def initialize(doc, lang = 'es')
    @lang = doc['lang'] || lang
    @title = doc['title']
    @subtitle = doc['subtitle']
    @slug = doc['slug']
    @cover = doc['cover']
    @type = doc['type']
    @level = doc['level']
    @downloadable = AppHelper::boolean_value(doc['downloadable'])
    @is_training_program = AppHelper::boolean_value(doc['is_training_program'])
  end

  def cover
    ImageUrlHelper.replace_s3_with_cdn(@cover)
  end

  def url
    raise NotImplementedError, "#{self.class} must implement the 'url' method"
  end

  def self.create(doc, lang= 'es')
    case doc['type']
    when 'article'
      RecommendedArticle.new(doc, lang)
    when 'event_type'
      RecommendedEventType.new(doc, lang)
    when 'service'
      RecommendedService.new(doc, lang)
    when 'resource'
      RecommendedResource.new(doc, lang)
    else
      puts "Unknown recommendation type: #{doc['type']}"
      # raise ArgumentError, "Unknown recommendation type: #{doc['type']}"
    end
  end

  def self.create_list(doc, lang= 'es')
    doc&.each_with_object([]) do |r, ac|
      recommendation = Recommended.create(r, lang)
      ac << recommendation if recommendation
    end || []
  end
end

class RecommendedArticle < Recommended
  def url
    "/es/blog/#{slug}"
  end
end

class RecommendedEventType < Recommended
  def initialize(doc, lang = 'es')
    super(doc, lang)
    @external_url = doc['external_url']
  end

  def url
    @external_url.empty? ? "/es/cursos/#{slug}" : @external_url
  end
end

class RecommendedService < Recommended
  def url
    if @lang == 'en'
      if @is_training_program
        "/en/training/#{slug}"
      else
        "/en/services/#{slug}"
      end
    else
      if @is_training_program
        "/es/formacion/#{slug}"
      else
        "/es/servicios/#{slug}"
      end
    end
  end
end

class RecommendedResource < Recommended
  def url
    if @lang == 'en'
      "/en/resources##{slug}"
    else
      "/es/recursos##{slug}"
    end
  end
end
