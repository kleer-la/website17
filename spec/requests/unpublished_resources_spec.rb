require 'spec_helper'
require './app'

# Unpublishing a resource in Keventer took it out of the list and the sitemap,
# but its page kept answering 200 with its content and links (#456). The API
# still returns it (the preview needs that), so the site decides: an
# unpublished resource is a 404, as an unpublished article already is; the
# team reviews a draft at /recursos/preview/<slug>, which no engine indexes.
describe 'an unpublished resource' do
  def app
    Sinatra::Application.new
  end

  def resource(published:, lang: 'es', redirect_url: nil)
    Resource.new({ 'id' => 1, 'redirect_url' => redirect_url, 'slug' => 'guia', 'slug_en' => 'guide', 'format' => 'concepts', 'published' => published,
                   'title_es' => 'Guía', 'title_en' => 'Guide', 'description_es' => 'texto-del-recurso',
                   'description_en' => 'texto-del-recurso',
                   'concepts' => [{ 'slug' => 'una-ficha', 'lang' => lang, 'name' => 'Ficha',
                                    'position' => 1 }] }, lang)
  end

  before do
    allow(Page).to receive(:load_from_keventer).and_return(Page.new)
    allow(Resource).to receive(:create_list_keventer).and_return([])
    allow(Resource).to receive(:create_one_keventer).and_raise(ResourceNotFoundError.new('other'))
  end

  {
    'es' => { path: '/es/recursos/guia', slug: 'guia' },
    'en' => { path: '/en/resources/guide', slug: 'guide' }
  }.each do |lang, data|
    context "in #{lang}" do
      it 'answers 404' do
        allow(Resource).to receive(:create_one_keventer).with(data[:slug], lang)
                                                        .and_return(resource(published: false, lang: lang))

        get data[:path]

        expect(last_response.status).to eq(404)
        expect(last_response.body).not_to include('texto-del-recurso')
      end

      it 'answers 404 for a card of a concepts resource too, which a published one serves' do
        allow(Resource).to receive(:create_one_keventer).with(data[:slug], lang)
                                                        .and_return(resource(published: false, lang: lang))

        get "#{data[:path]}/una-ficha"
        expect(last_response.status).to eq(404)

        allow(Resource).to receive(:create_one_keventer).with(data[:slug], lang)
                                                        .and_return(resource(published: true, lang: lang))
        get "#{data[:path]}/una-ficha"
        expect(last_response.status).to eq(200)
      end

      # Same shape as an article: the retired page forwards to its replacement
      # before the published check (eventer#236).
      it 'answers 301 to its redirect_url when it has one, published or not' do
        allow(Resource).to receive(:create_one_keventer).with(data[:slug], lang)
                                                        .and_return(resource(published: false, lang: lang,
                                                                             redirect_url: '/es/recursos/otro'))

        get data[:path]
        expect(last_response.status).to eq(301)
        expect(last_response.location).to end_with('/es/recursos/otro')

        get "#{data[:path]}/una-ficha"
        expect(last_response.status).to eq(301)
        expect(last_response.location).to end_with('/es/recursos/otro')
      end

      it 'does not forward the preview, where the team reads the draft' do
        allow(Resource).to receive(:create_one_keventer).with(data[:slug], lang)
                                                        .and_return(resource(published: false, lang: lang,
                                                                             redirect_url: '/es/recursos/otro'))

        get data[:path].sub(%r{/(recursos|resources)/}, '/\1/preview/')

        expect(last_response.status).to eq(200)
      end

      it 'is still found by the team at the preview path, out of the search engines' do
        allow(Resource).to receive(:create_one_keventer).with(data[:slug], lang)
                                                        .and_return(resource(published: false, lang: lang))

        get data[:path].sub(%r{/(recursos|resources)/}, '/\1/preview/')

        expect(last_response.status).to eq(200)
        expect(last_response.body).to match(/<meta name="robots" content="noindex, ?nofollow"/)
      end

      it 'does not hurt a published resource' do
        allow(Resource).to receive(:create_one_keventer).with(data[:slug], lang)
                                                        .and_return(resource(published: true, lang: lang))

        get data[:path]

        expect(last_response.status).to eq(200)
        expect(last_response.body).not_to include('noindex')
      end
    end
  end

  it 'counts a resource whose API answer carries no flag as published' do
    expect(Resource.new({ 'slug' => 'x' }, 'es').published).to be(true)
  end

  # The preview list is where the team finds a draft: its cards must open the
  # draft, not the public path that now answers 404.
  describe 'the preview list' do
    before do
      allow(Resource).to receive(:create_list_keventer).and_return([resource(published: false, lang: :es)])
    end

    it 'links each card to its preview page' do
      get '/es/recursos/preview'

      expect(last_response.body).to include('href="/es/recursos/preview/guia"')
      expect(last_response.body).not_to include('href="/es/recursos/guia"')
    end

    it 'leaves the public list linking to the public pages' do
      get '/es/recursos'

      expect(last_response.body).to include('href="/es/recursos/guia"')
      expect(last_response.body).not_to include('/recursos/preview/guia')
    end
  end
end
