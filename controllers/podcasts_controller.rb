require './lib/models/podcast'

# set :podcasts, Podcast.load_from_json('./lib/storage/podcasts.json')
# set :podcasts, Podcast.load_from_keventer

get '/podcasts' do
  page = Page.load_from_keventer(session[:locale], 'podcasts')
  @meta_tags.set! title: page.seo_title || t('meta_tag.podcasts.title'),
                  description: page.seo_description || t('meta_tag.podcasts.description'),
                  canonical: page.canonical || t('meta_tag.podcasts.canonical')

  @meta_tags.set! image: page.cover unless page.cover.nil?

  @podcasts = Podcast.load_from_keventer
  @carousel = @podcasts.first(3)
  # @recent_episodes = @podcasts.flat_map(&:episodes).sort_by { |episode| episode['released_at'] }.last(3)

  @episodes = @podcasts.flat_map do |podcast|
    podcast.episodes.map do |episode|
      episode.merge('podcast_title' => podcast.title)
    end
  end
  # `released_at` is when the episode came out on Spotify / YouTube. Keventer
  # called it `published_at` until that name was taken by the flag for whether
  # the episode shows on the site at all — which is why this list only ever
  # holds published ones now.
  @episodes.sort_by! { |episode| Date.parse(episode['released_at']) }.reverse!
  @recent_episodes = @episodes.shift(4)

  render_page :'podcasts/index'
end
