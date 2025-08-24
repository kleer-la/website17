require_relative '../../spec_helper'
require './lib/models/podcast'

RSpec.describe Podcast do
  describe '#initialize' do
    let(:podcast_data) do
      {
        'id' => 1,
        'title' => 'Test Podcast',
        'description_body' => 'Test description',
        'thumbnail_url' => 'https://kleer-images.s3.sa-east-1.amazonaws.com/podcast-cover.jpg',
        'episodes' => [
          {
            'title' => 'Episode 1',
            'thumbnail_url' => 'https://kleer-images.s3.sa-east-1.amazonaws.com/episode1.jpg'
          },
          {
            'title' => 'Episode 2',
            'thumbnail_url' => 'https://kleer-images.s3.sa-east-1.amazonaws.com/episode2.jpg'
          },
          {
            'title' => 'Episode 3',
            'thumbnail_url' => nil
          }
        ]
      }
    end

    it 'replaces S3 URLs with CDN URLs in podcast thumbnail_url' do
      podcast = Podcast.new(podcast_data)
      
      expect(podcast.thumbnail_url).to eq('https://d3vnsn21cv5bcd.cloudfront.net/podcast-cover.jpg')
    end

    it 'replaces S3 URLs with CDN URLs in episode thumbnail_urls' do
      podcast = Podcast.new(podcast_data)
      
      expect(podcast.episodes[0]['thumbnail_url']).to eq('https://d3vnsn21cv5bcd.cloudfront.net/episode1.jpg')
      expect(podcast.episodes[1]['thumbnail_url']).to eq('https://d3vnsn21cv5bcd.cloudfront.net/episode2.jpg')
    end

    it 'handles episodes with nil thumbnail_url' do
      podcast = Podcast.new(podcast_data)
      
      expect(podcast.episodes[2]['thumbnail_url']).to be_nil
    end

    it 'does not modify original episode hashes' do
      original_episodes = podcast_data['episodes'].dup
      podcast = Podcast.new(podcast_data)
      
      # Original data should remain unchanged
      expect(original_episodes[0]['thumbnail_url']).to eq('https://kleer-images.s3.sa-east-1.amazonaws.com/episode1.jpg')
      # But podcast episodes should be updated
      expect(podcast.episodes[0]['thumbnail_url']).to eq('https://d3vnsn21cv5bcd.cloudfront.net/episode1.jpg')
    end
  end
end