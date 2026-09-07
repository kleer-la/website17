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
    CacheService.clear
    allow(Page).to receive(:load_from_keventer).and_return(Page.new)
    allow(News).to receive(:create_list_keventer).and_return([])
    allow(Podcast).to receive(:load_from_keventer).and_return([])
    allow(Event).to receive(:create_keventer_json).and_return([])
    allow(Catalog).to receive(:create_keventer_json).and_return([])
    allow(ServiceAreaV3).to receive(:try_create_list_keventer).and_return([])
    allow(Category).to receive(:create_keventer_json).and_return([])
  end

  after { CacheService.clear }

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

  # The agenda has no English edition either, and for a reason of its own:
  # there are no open editions to list, and the page loaded them without
  # filtering by language, so the English URL announced Spanish courses. The
  # menu already hid it while there were none — but on `has_open_events`, which
  # counts every language, so one Spanish edition brought the English item back.
  describe 'the agenda' do
    it_behaves_like 'a section with no English edition', '/es/agenda', '/en/schedule'

    context 'when there are open editions' do
      before do
        allow(Event).to receive(:create_keventer_json).and_return([double(date: Date.today)])
      end

      it 'still keeps it out of the English menu' do
        get '/en/catalog'

        expect(last_response.body).not_to include('href="/en/schedule"')
      end

      it 'keeps offering it in Spanish' do
        get '/es/catalogo'

        expect(last_response.body).to include('href="/es/agenda"')
      end
    end
  end
end
