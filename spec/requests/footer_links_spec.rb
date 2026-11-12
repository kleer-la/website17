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

  # Column and dialog titles are not part of the page's content: as h5 they
  # hung from whatever heading came last on each page (website17#460).
  context 'headings' do
    let(:html) do
      get '/es/'
      Nokogiri::HTML(last_response.body)
    end

    def headings(css)
      html.css(css).flat_map { |el| el.css('h1, h2, h3, h4, h5, h6') }.map { |h| h.text.strip }
    end

    it 'has none in the footer' do
      expect(headings('footer')).to be_empty
    end

    it 'has none in the dialogs' do
      expect(headings('.modal')).to be_empty
    end

    it 'keeps the titles, styled as before' do
      expect(html.css('footer .h5').map { |t| t.text.strip }).to include('Qué hacemos', 'Suscríbete')
      expect(html.css('.modal .modal-title.h5')).not_to be_empty
    end
  end
end
