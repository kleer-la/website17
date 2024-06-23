class Podcast
  attr_accessor :title, :description, :seasons, :youtube_url, :spotify_url, :thumbnail_url, :episodes

  def initialize(title, description, seasons, youtube_url, spotify_url, thumbnail_url, episodes = [])
    @title = title
    @description = description
    @seasons = seasons
    @youtube_url = youtube_url
    @spotify_url = spotify_url
    @thumbnail_url = thumbnail_url
    @episodes = episodes
  end

  def self.load_from_json(file_path)
    data = JSON.parse(File.read(file_path))
    data['podcasts'].map do |podcast_data|
      new(
        podcast_data['title'],
        podcast_data['description'],
        podcast_data['seasons'],
        podcast_data['youtube_url'],
        podcast_data['spotify_url'],
        podcast_data['thumbnail_url'],
        podcast_data['episodes']
      )
    end
  end
end
