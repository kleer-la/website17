require './lib/models/podcast'

# set :podcasts, Podcast.load_from_json('./lib/storage/podcasts.json')
# set :podcasts, Podcast.load_from_keventer

get '/podcasts' do
  @meta_tags.set! title: t('meta_tag.podcasts.title'),
                  description: t('meta_tag.podcasts.description'),
                  canonical: t('meta_tag.podcasts.canonical')

  # @podcasts = settings.podcasts
  @podcasts = Podcast.load_from_keventer
  @carousel = @podcasts.first(3)
  # @recent_episodes = @podcasts.flat_map(&:episodes).sort_by { |episode| episode['published_at'] }.last(3)

  @recent_episodes = @podcasts.flat_map do |podcast|
    podcast.episodes.map do |episode|
      episode.merge('podcast_title' => podcast.title)
    end
  end.sort_by { |episode| episode['published_at'] }.last(4).reverse
    
  erb :'podcasts/index', layout: :'layout/layout2022'
end
