require './lib/services/api_accessible'
require './lib/services/keventer_api'

class Podcast
  include APIAccessible

  api_connector KeventerAPI

  attr_accessor :title, :description, :seasons, :youtube_url, :spotify_url, :thumbnail_url, :episodes

  def initialize(data)
    @id = data['id']
    @title = data['title']
    @description = data['description_body']
    @seasons = data['seasons']
    @youtube_url = data['youtube_url']
    @spotify_url = data['spotify_url']
    @thumbnail_url = data['thumbnail_url']
    @episodes = data['episodes'] || []
  end

  def self.load_from_json(file_path)
    data = JSON.parse(File.read(file_path))
    data['podcasts'].map do |podcast_data|
      new(podcast_data)
    end
  end

  def self.load_from_keventer
    url = KeventerAPI.podcasts_url
    json_api = JsonAPI.new(url)
    load(json_api)
  end

  def self.load(json_api)
    json_api.doc.map { |podcast_data| new(podcast_data) } if json_api.ok?
  end
end
