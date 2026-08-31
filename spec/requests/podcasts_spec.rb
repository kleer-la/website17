require 'spec_helper'
require './app'

# The podcasts page orders episodes by when they came out on Spotify / YouTube.
# Keventer calls that `released_at`; it used to call it `published_at`, a name it
# now uses for whether the episode is shown on the site at all.
describe 'GET /podcasts' do
  def app
    Sinatra::Application.new
  end

  def episode(title, released_at)
    { 'title' => title, 'released_at' => released_at, 'description_body' => "sobre #{title}",
      'youtube_url' => 'https://youtu.be/x', 'spotify_url' => '', 'thumbnail_url' => nil }
  end

  before do
    allow(Page).to receive(:load_from_keventer).and_return(Page.new)
    allow(Podcast).to receive(:load_from_keventer).and_return(
      [Podcast.new('title' => 'Kleer Podcast', 'episodes' => [episode('Antiguo', '2024-01-15'),
                                                              episode('Reciente', '2026-06-30')])]
    )
  end

  it 'renders' do
    get '/podcasts'

    expect(last_response.status).to eq(200)
    expect(last_response.body).to include('Reciente').and include('Antiguo')
  end

  it 'orders the episodes by release date, newest first' do
    get '/podcasts'

    expect(last_response.body.index('Reciente')).to be < last_response.body.index('Antiguo')
  end
end
