require 'oauth'
require 'json'

require './lib/tweet'

class TwitterReader
  def initialize
    # If your are a kleerer, grab the keys from the usual (safe) key storage.
    @access_token = ENV['TWITTER_ACCESS_TOKEN']
    @access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
    @consumer_key = ENV['TWITTER_CONSUMER_KEY']
    @consumer_secret = ENV['TWITTER_CONSUMER_SECRET']

    @modo_test = false

    if @access_token.nil? || @access_token_secret.nil? ||
       @consumer_key.nil? || @consumer_secret.nil?
      @modo_test = true
    end
  end

  def last_tweet(screen_name)
    return Tweet.new('111111111', 'Test tweet message') if @modo_test

    token = prepare_access_token(@access_token, @access_token_secret)

    # use the access token as an agent to get the home timeline
    response = token.request(:get,
                             "https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=#{screen_name}&trim_user=true&include_rts=true&count=1")

    tweets = JSON.parse(response.body)

    return Tweet.new('', 'Invalid twitter account') if tweets[0].nil?

    Tweet.new(tweets[0]['user']['id_str'], tweets[0]['text'])
  end

  private

  # Exchange your oauth_token and oauth_token_secret for an AccessToken instance.
  def prepare_access_token(oauth_token, oauth_token_secret)
    consumer = OAuth::Consumer.new(@consumer_key, @consumer_secret,
                                   { site: 'https://api.twitter.com', scheme: :header })

    token_hash = { oauth_token: oauth_token, oauth_token_secret: oauth_token_secret }

    OAuth::AccessToken.from_hash(consumer, token_hash)
  end
end
