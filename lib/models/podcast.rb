require './lib/services/api_accessible'
require './lib/services/keventer_api'
require './lib/image_url_helper'

class Podcast
  include APIAccessible

  api_connector KeventerAPI

  attr_accessor :title, :description, :seasons, :youtube_url, :spotify_url, :episodes

  def initialize(data)
    @id = data['id']
    @title = data['title']
    @description = data['description_body']
    @seasons = data['seasons']
    @youtube_url = data['youtube_url']
    @spotify_url = data['spotify_url']
    @thumbnail_url = data['thumbnail_url']
    @episodes = process_episodes(data['episodes'] || [])
  end

  def thumbnail_url
    ImageUrlHelper.replace_s3_with_cdn(@thumbnail_url)
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

  private

  def process_episodes(episodes)
    episodes.map do |episode|
      if episode['thumbnail_url']
        episode = episode.dup
        episode['thumbnail_url'] = ImageUrlHelper.replace_s3_with_cdn(episode['thumbnail_url'])
      end
      episode
    end
  end
end
