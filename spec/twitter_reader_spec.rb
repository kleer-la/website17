require './lib/twitter_reader'
require 'spec_helper'

describe TwitterReader do
  before(:each) do
    @reader = TwitterReader.new
  end

  it 'should return a tweet for the kleer_la account' do
    @reader.last_tweet('kleer_la').user_id.should == '111111111'
  end
end
