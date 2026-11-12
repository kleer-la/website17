require 'spec_helper'
require './app'
require 'nokogiri'

# The site's styles are plain CSS with no build step (website17#464). The
# files of public/app/css/site are the source; the site serves them joined in
# one stylesheet, palette first, in the order the old Sass imports had, so the
# cascade is the one the site always had and the browser makes one request.
describe 'the site stylesheet' do
  def app
    Sinatra::Application.new
  end

  before do
    allow(Page).to receive(:load_from_keventer).and_return(Page.new)
  end

  let(:linked) do
    get '/es/'
    Nokogiri::HTML(last_response.body).css('head link[rel=stylesheet]')
            .map { |l| l['href'] }.grep(%r{^/app/css/})
  end

  let(:files) do
    %w[tokens home training blog news clients about_us UIKit services business-agility
       recommended resources slider contact bookings recommended_way concepts index]
  end

  it 'is a single stylesheet, versioned by its newest file' do
    newest = files.map { File.mtime("public/app/css/site/#{_1}.css").to_i }.max

    expect(linked).to eq ["/app/css/site.css?v=#{newest}"]
  end

  describe 'its body' do
    before { get '/app/css/site.css' }

    let(:css) { last_response.body }

    it 'is served as CSS' do
      expect(last_response.status).to eq 200
      expect(last_response.content_type).to start_with 'text/css'
    end

    it 'joins every site file, in cascade order' do
      expect(css.scan(%r{^/\* site/(\S+)\.css \*/$}).flatten).to eq files
    end

    it 'keeps each file whole, but for the lines it hoists' do
      files.each do |name|
        rules = File.read("public/app/css/site/#{name}.css").lines.grep_v(/\A@(charset|import)\b/).join

        expect(css).to include("/* site/#{name}.css */\n#{rules.strip}\n"), "#{name}.css is not whole"
      end
    end

    it 'opens with the charset, once' do
      expect(css.lines.first).to start_with '@charset "UTF-8";'
      expect(css.scan('@charset').size).to eq 1
    end

    # An @import is only fetched once this stylesheet has arrived, which puts
    # one more round trip before the first paint (website17#465).
    it 'imports nothing' do
      expect(css).not_to include '@import'
    end
  end

  it 'asks for the web fonts from the head, next to the stylesheet' do
    get '/es/'
    head = Nokogiri::HTML(last_response.body).at_css('head')

    expect(head.at_css('link[rel=preconnect][href="https://fonts.gstatic.com"][crossorigin]')).not_to be_nil
    expect(head.at_css('link[rel=stylesheet][href^="https://fonts.googleapis.com/css2?family=Raleway"]')['href'])
      .to end_with '&display=swap'
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
