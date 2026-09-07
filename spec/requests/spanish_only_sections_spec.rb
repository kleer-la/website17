require 'spec_helper'
require './app'

# Novedades and Podcasts have no English edition: the records behind them carry
# no translation, so /en/news and /en/podcasts answered 200 with the Spanish
# copy under <html lang="en">, in the sitemap and with nothing telling a crawler
# to skip them. A URL that declares a language it does not speak is worse than a
# missing one — it spends the crawl and shows a reader a page they cannot read.
describe 'sections that exist only in Spanish' do
  def app
    Sinatra::Application.new
  end

  before do
    allow(Page).to receive(:load_from_keventer).and_return(Page.new)
    allow(News).to receive(:create_list_keventer).and_return([])
    allow(Podcast).to receive(:load_from_keventer).and_return([])
  end

  shared_examples 'a section with no English edition' do |es_path, en_path|
    it "keeps #{en_path} out of the index" do
      get en_path

      expect(last_response.body).to include('<meta name="robots" content="noindex,nofollow"/>')
    end

    it "does not declare an English alternate on #{en_path}" do
      get en_path

      expect(last_response.body).not_to include('hreflang="en"')
    end

    it "does not promise one from #{es_path} either" do
      get es_path

      expect(last_response.body).not_to include('hreflang="en"')
      expect(last_response.body).to include("hreflang=\"es\" href=\"https://www.kleer.la#{es_path}\"")
    end

    it "leaves #{es_path} indexable" do
      get es_path

      expect(last_response.body).not_to include('name="robots"')
    end
  end

  it_behaves_like 'a section with no English edition', '/es/novedades', '/en/news'
  it_behaves_like 'a section with no English edition', '/es/podcasts', '/en/podcasts'
end
