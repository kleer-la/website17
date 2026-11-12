require 'spec_helper'
require './app'
require 'nokogiri'

# The site's styles are plain CSS with no build step (website17#464): the
# layout links each file of public/app/css/site, palette first, in the order
# the old Sass imports had, so the cascade is the one the site always had.
describe 'the site stylesheets' do
  def app
    Sinatra::Application.new
  end

  before do
    allow(Page).to receive(:load_from_keventer).and_return(Page.new)
  end

  let(:linked) do
    get '/es/'
    Nokogiri::HTML(last_response.body).css('head link[rel=stylesheet]')
            .map { |l| l['href'][%r{^/app/css/([^?]+)}, 1] }.compact
  end

  it 'links the palette first and then every site file, in cascade order' do
    expected = %w[tokens home training blog news clients about_us UIKit services business-agility
                  recommended resources slider contact bookings recommended_way concepts index]

    expect(linked).to eq(expected.map { "site/#{_1}.css" })
  end

  it 'serves every file it links' do
    linked.each do |file|
      get "/app/css/#{file}"
      expect(last_response.status).to eq(200), "#{file} answered #{last_response.status}"
    end
  end

  # A relative url() resolves from the stylesheet's own folder, so moving a
  # file breaks it silently; local images are written from the site root.
  it 'points every local url() at a file that exists' do
    missing = Dir.glob('public/app/css/**/*.css').flat_map do |css|
      File.read(css).scan(/url\(\s*["']?([^"')]+)["']?\s*\)/).flatten
          .reject { |url| url.match?(%r{\A(https?:|data:|//)}) }
          .map { |url| url.start_with?('/') ? "public#{url}" : File.expand_path(url, File.dirname(css)) }
          .reject { |path| File.exist?(path.sub(/[?#].*/, '')) }
          .map { |path| "#{css}: #{path}" }
    end

    expect(missing).to be_empty
  end

  it 'has no Sass sources left to drift from the CSS' do
    expect(Dir.glob('public/app/**/*.{scss,sass}')).to be_empty
  end
end
