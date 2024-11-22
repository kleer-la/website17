require './lib/services/keventer_api'
require './lib/trainer'

module NullInfra
end

module LoadTrainers
  def load_trainers(hash_trainers)
    return [] if hash_trainers.nil?

    hash_trainers.reduce([]) do |trainers, t_json|
      trainers << Trainer.new.load_from_json(t_json)
    end
  end

  # Just a name array
  def trainer_names(doc)
    doc['trainers']&.reduce([]) { |ac, t| ac << t['name'] } || []
  end
end

class News
  extend NullInfra
  include LoadTrainers

  @next_null = false

  def self.create_list_null(doc, opt = {})
    @next_null = opt[:next_null] == true
    @result = News.load_list(doc)
  end

  def self.create_list_keventer
    if @next_null
      @next_null = false
      return @result
    end
    api_resp = JsonAPI.new(KeventerAPI.news_url)
    raise :NotFound unless api_resp.ok?

    News.load_list(api_resp.doc)
  end

  attr_accessor :title, :where, :description, :img, :url,
                :trainers, :trainers_list, :lang, :event_date,
                :created_at, :updated_at

  def initialize(doc)
    @id = doc['id']
    @title = doc['title']
    @where = doc['where']
    @description = doc['description']
    @lang = doc['lang']
    @img = doc['img'] || ''
    @url = doc['url'] || ''
    @event_date = parse_date(doc['event_date'])
    @trainers_list = load_trainers(doc['trainers'])
    @trainers = trainer_names(doc)
    init_dates(doc)
  end

  def init_dates(doc)
    @created_at = doc['created_at'] || ''
    @updated_at = doc['updated_at'] || ''
  end

  def self.load_list(doc)
    doc.each_with_object([]) do |elem, ac|
      ac << News.new(elem)
    end
  end

  private

  def parse_date(date_str)
    begin
      return '' if date_str.nil? || date_str.empty?
      Date.parse(date_str).strftime('%d-%m-%Y')
    rescue Date::Error
      ''
    end
  end
end
