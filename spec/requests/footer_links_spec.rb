require 'spec_helper'
require './app'
require 'nokogiri'

# The footer is built from a list in the locale files, and an entry with no
# title and no url still renders: an anchor with no text pointing at the
# language home, on every page of that language.
describe 'the footer' do
  def app
    Sinatra::Application.new
  end

  before do
    allow(Page).to receive(:load_from_keventer).and_return(Page.new)
  end

  %w[es en].each do |lang|
    it "has no empty link in #{lang}" do
      get "/#{lang}/"

      # An icon link is empty of text but carries an image; this is about the
      # ones that carry nothing at all.
      empty = Nokogiri::HTML(last_response.body).css('footer a')
                                                .select { |a| a.text.strip.empty? && a.element_children.empty? }
      expect(empty.map { |a| a['href'] }).to be_empty
    end
  end
end
