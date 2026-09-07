require 'spec_helper'
require './lib/helpers/router_helper'
require './lib/models/resources'

describe RouterHelper do
  let(:router_helper) { RouterHelper.new }

  describe 'ROUTE_TRANSLATIONS' do
    it 'contains mapping for recursos/resources' do
      expect(RouterHelper::ROUTE_TRANSLATIONS['recursos']).to eq({ es: 'recursos', en: 'resources' })
      expect(RouterHelper::ROUTE_TRANSLATIONS['resources']).to eq({ es: 'recursos', en: 'resources' })
    end

    it 'contains mapping for blog' do
      expect(RouterHelper::ROUTE_TRANSLATIONS['blog']).to eq({ es: 'blog', en: 'blog' })
    end

    it 'contains mapping for catalogo/catalog' do
      expect(RouterHelper::ROUTE_TRANSLATIONS['catalogo']).to eq({ es: 'catalogo', en: 'catalog' })
      expect(RouterHelper::ROUTE_TRANSLATIONS['catalog']).to eq({ es: 'catalogo', en: 'catalog' })
    end

    it 'contains mapping for novedades/news' do
      expect(RouterHelper::ROUTE_TRANSLATIONS['novedades']).to eq({ es: 'novedades', en: 'news' })
      expect(RouterHelper::ROUTE_TRANSLATIONS['news']).to eq({ es: 'novedades', en: 'news' })
    end

    it 'contains mapping for clientes/clients' do
      expect(RouterHelper::ROUTE_TRANSLATIONS['clientes']).to eq({ es: 'clientes', en: 'clients' })
      expect(RouterHelper::ROUTE_TRANSLATIONS['clients']).to eq({ es: 'clientes', en: 'clients' })
    end
  end

  # The language alternates fall back to the current path when the controller
  # does not spell them out. Swapping only the prefix names /en/recursos, which
  # redirects; the section table already knows the pair.
  describe '.translate_first_segment' do
    it 'translates the section of an index path' do
      expect(RouterHelper.translate_first_segment('/recursos', 'en')).to eq '/resources'
    end

    it 'translates the section and keeps the rest of the path' do
      expect(RouterHelper.translate_first_segment('/recursos/dod-kards', 'en')).to eq '/resources/dod-kards'
    end

    it 'translates back' do
      expect(RouterHelper.translate_first_segment('/resources/dod-kards', 'es')).to eq '/recursos/dod-kards'
    end

    # A section the table does not know keeps the path it has: /privacy and
    # /podcasts are the same URL in both languages, and inventing a
    # counterpart for them would take away an alternate that works.
    it 'leaves a section it does not know alone' do
      expect(RouterHelper.translate_first_segment('/privacy', 'en')).to eq '/privacy'
      expect(RouterHelper.translate_first_segment('/podcasts', 'en')).to eq '/podcasts'
    end

    it 'leaves the language home alone' do
      expect(RouterHelper.translate_first_segment('', 'en')).to eq ''
      expect(RouterHelper.translate_first_segment('/', 'en')).to eq '/'
    end
  end

  # A section names its own language: /services is the English value in the
  # table, /servicios the Spanish one. Everything the table does not know has
  # no language to name, and stays where it is.
  # The controller needs to know whether a translation is really there: it is
  # what decides between declaring one language and declaring two.
  describe '#set_alternate_route_with_fallback returning the translation' do
    let(:translated) { double('Resource', title: 'Definition of Done', slug: 'dod-kards') }
    let(:untranslated) { double('Resource', title: '', slug: 'poster-scrum') }

    it 'gives back the slug the content has in the other language' do
      allow(Resource).to receive(:create_one_keventer).with('dod-kards', 'en').and_return(translated)

      expect(router_helper.set_alternate_route_with_fallback('recursos', 'dod-kards', 'es', Resource))
        .to eq 'dod-kards'
    end

    it 'gives back nothing when there is no version in the other language' do
      allow(Resource).to receive(:create_one_keventer).with('poster-scrum', 'en').and_return(untranslated)

      expect(router_helper.set_alternate_route_with_fallback('recursos', 'poster-scrum', 'es', Resource))
        .to be_nil
    end

    it 'gives back nothing when the other language cannot be loaded' do
      allow(Resource).to receive(:create_one_keventer).and_raise(StandardError)

      expect(router_helper.set_alternate_route_with_fallback('recursos', 'poster-scrum', 'es', Resource))
        .to be_nil
    end
  end

  describe '.language_of_path' do
    it 'reads English from an English section' do
      expect(RouterHelper.language_of_path('/services')).to eq 'en'
      expect(RouterHelper.language_of_path('/about_us')).to eq 'en'
      expect(RouterHelper.language_of_path('/resources/dod-kards')).to eq 'en'
    end

    it 'reads Spanish from a Spanish section' do
      expect(RouterHelper.language_of_path('/servicios')).to eq 'es'
      expect(RouterHelper.language_of_path('/somos')).to eq 'es'
    end

    it 'takes a section that is the same in both for Spanish' do
      expect(RouterHelper.language_of_path('/blog')).to eq 'es'
    end

    it 'says nothing about a path that already has a prefix' do
      expect(RouterHelper.language_of_path('/es/servicios')).to be_nil
      expect(RouterHelper.language_of_path('/en/services')).to be_nil
    end

    # The routes that are not content: a prefix would send a form post or a
    # utility file somewhere it was never meant to go.
    it 'says nothing about a section it does not know' do
      expect(RouterHelper.language_of_path('/events/1/participants/register')).to be_nil
      expect(RouterHelper.language_of_path('/assessment/7')).to be_nil
      expect(RouterHelper.language_of_path('/robots.txt')).to be_nil
      expect(RouterHelper.language_of_path('/s/abc')).to be_nil
      expect(RouterHelper.language_of_path('/cache-reset')).to be_nil
    end

    it 'says nothing about the root' do
      expect(RouterHelper.language_of_path('/')).to be_nil
      expect(RouterHelper.language_of_path('')).to be_nil
    end
  end

  describe '#set_current_route' do
    it 'removes language prefix from route' do
      router_helper.set_current_route('/es/recursos/some-slug')
      expect(router_helper.current_route).to eq('/recursos/some-slug')
    end

    it 'handles English prefix' do
      router_helper.set_current_route('/en/resources/some-slug')
      expect(router_helper.current_route).to eq('/resources/some-slug')
    end

    it 'keeps route without language prefix' do
      router_helper.set_current_route('/recursos/some-slug')
      expect(router_helper.current_route).to eq('/recursos/some-slug')
    end
  end

  describe '#get_alternate_route' do
    it 'translates the current route when alternate is not set' do
      router_helper.set_current_route('/es/recursos')
      expect(router_helper.get_alternate_route).to eq('/resources')
    end

    it 'returns alternate route when set' do
      router_helper.set_current_route('/es/recursos')
      router_helper.alternate_route = '/resources/some-slug'
      expect(router_helper.get_alternate_route).to eq('/resources/some-slug')
    end
  end

  # The switcher is the same fallback the hreflang had before #408: without an
  # alternate spelled out it offered the current path with the prefix swapped,
  # so ESPAÑOL/ENGLISH on /es/recursos pointed at /en/recursos, a redirect.
  describe '#get_alternate_route translating the section' do
    it 'offers the section under its name in the other language' do
      helper = RouterHelper.new
      helper.lang = 'es'
      helper.set_current_route('/es/recursos')

      expect(helper.get_alternate_route).to eq '/resources'
    end

    it 'translates back' do
      helper = RouterHelper.new
      helper.lang = 'en'
      helper.set_current_route('/en/resources/dod-kards')

      expect(helper.get_alternate_route).to eq '/recursos/dod-kards'
    end

    it 'leaves a section it does not know alone' do
      helper = RouterHelper.new
      helper.lang = 'es'
      helper.set_current_route('/es/podcasts')

      expect(helper.get_alternate_route).to eq '/podcasts'
    end
  end

  describe '#set_alternate_route_with_fallback' do
    let(:alternate_resource_with_content) { double('Resource', slug: 'same-slug', title: 'Translated Title') }
    let(:alternate_resource_empty) { double('Resource', slug: 'same-slug', title: '') }

    context 'when translating from Spanish to English' do
      context 'when translated resource has content' do
        it 'sets alternate route to the same slug in English' do
          allow(Resource).to receive(:create_one_keventer)
            .with('same-slug', 'en')
            .and_return(alternate_resource_with_content)

          router_helper.set_alternate_route_with_fallback('recursos', 'same-slug', 'es', Resource)

          expect(router_helper.alternate_route).to eq('/resources/same-slug')
        end
      end

      context 'when translated resource has no content (empty title)' do
        it 'sets alternate route to the resources index' do
          allow(Resource).to receive(:create_one_keventer)
            .with('same-slug', 'en')
            .and_return(alternate_resource_empty)

          router_helper.set_alternate_route_with_fallback('recursos', 'same-slug', 'es', Resource)

          expect(router_helper.alternate_route).to eq('/resources')
        end
      end

      context 'when API raises an error' do
        it 'sets alternate route to the resources index' do
          allow(Resource).to receive(:create_one_keventer)
            .with('same-slug', 'en')
            .and_raise(ResourceNotFoundError.new('same-slug'))

          router_helper.set_alternate_route_with_fallback('recursos', 'same-slug', 'es', Resource)

          expect(router_helper.alternate_route).to eq('/resources')
        end
      end
    end

    context 'when translating from English to Spanish' do
      context 'when translated resource has content' do
        it 'sets alternate route to the same slug in Spanish' do
          allow(Resource).to receive(:create_one_keventer)
            .with('same-slug', 'es')
            .and_return(alternate_resource_with_content)

          router_helper.set_alternate_route_with_fallback('resources', 'same-slug', 'en', Resource)

          expect(router_helper.alternate_route).to eq('/recursos/same-slug')
        end
      end

      context 'when translated resource has no content (empty title)' do
        it 'sets alternate route to the recursos index' do
          allow(Resource).to receive(:create_one_keventer)
            .with('same-slug', 'es')
            .and_return(alternate_resource_empty)

          router_helper.set_alternate_route_with_fallback('resources', 'same-slug', 'en', Resource)

          expect(router_helper.alternate_route).to eq('/recursos')
        end
      end

      context 'when API raises an error' do
        it 'sets alternate route to the recursos index' do
          allow(Resource).to receive(:create_one_keventer)
            .with('same-slug', 'es')
            .and_raise(ResourceNotFoundError.new('same-slug'))

          router_helper.set_alternate_route_with_fallback('resources', 'same-slug', 'en', Resource)

          expect(router_helper.alternate_route).to eq('/recursos')
        end
      end
    end

    context 'when base_path is not in ROUTE_TRANSLATIONS' do
      it 'does not set alternate route' do
        router_helper.alternate_route = '/original-route'

        router_helper.set_alternate_route_with_fallback('unknown-path', 'some-slug', 'es', Resource)

        expect(router_helper.alternate_route).to eq('/original-route')
      end
    end

    context 'when any other error occurs' do
      it 'sets alternate route to the index' do
        allow(Resource).to receive(:create_one_keventer)
          .with('some-slug', 'en')
          .and_raise(StandardError.new('API error'))

        router_helper.set_alternate_route_with_fallback('recursos', 'some-slug', 'es', Resource)

        expect(router_helper.alternate_route).to eq('/resources')
      end
    end
  end

  describe '.instance' do
    it 'returns a singleton instance' do
      instance1 = RouterHelper.instance
      instance2 = RouterHelper.instance

      expect(instance1).to be(instance2)
    end
  end

  describe '.alternate_path' do
    context 'when current language is Spanish' do
      it 'returns English path for recursos' do
        expect(RouterHelper.alternate_path('recursos', 'es')).to eq('/resources')
      end

      it 'returns English path for servicios' do
        expect(RouterHelper.alternate_path('servicios', 'es')).to eq('/services')
      end

      it 'returns English path for catalogo' do
        expect(RouterHelper.alternate_path('catalogo', 'es')).to eq('/catalog')
      end

      it 'returns English path for agenda' do
        expect(RouterHelper.alternate_path('agenda', 'es')).to eq('/schedule')
      end

      it 'returns English path for formacion' do
        expect(RouterHelper.alternate_path('formacion', 'es')).to eq('/training')
      end

      it 'returns English path for somos' do
        expect(RouterHelper.alternate_path('somos', 'es')).to eq('/about_us')
      end

      it 'keeps blog as blog' do
        expect(RouterHelper.alternate_path('blog', 'es')).to eq('/blog')
      end
    end

    context 'when current language is English' do
      it 'returns Spanish path for resources' do
        expect(RouterHelper.alternate_path('resources', 'en')).to eq('/recursos')
      end

      it 'returns Spanish path for services' do
        expect(RouterHelper.alternate_path('services', 'en')).to eq('/servicios')
      end

      it 'returns Spanish path for catalog' do
        expect(RouterHelper.alternate_path('catalog', 'en')).to eq('/catalogo')
      end

      it 'returns Spanish path for schedule' do
        expect(RouterHelper.alternate_path('schedule', 'en')).to eq('/agenda')
      end

      it 'returns Spanish path for training' do
        expect(RouterHelper.alternate_path('training', 'en')).to eq('/formacion')
      end

      it 'returns Spanish path for about_us' do
        expect(RouterHelper.alternate_path('about_us', 'en')).to eq('/somos')
      end

      it 'keeps blog as blog' do
        expect(RouterHelper.alternate_path('blog', 'en')).to eq('/blog')
      end
    end

    context 'when locale is a symbol' do
      it 'works with symbol locale' do
        expect(RouterHelper.alternate_path('recursos', :es)).to eq('/resources')
        expect(RouterHelper.alternate_path('resources', :en)).to eq('/recursos')
      end
    end

    context 'when path has no translation' do
      it 'returns the path with alternate language attempt' do
        expect(RouterHelper.alternate_path('unknown', 'es')).to eq('/unknown')
        expect(RouterHelper.alternate_path('unknown', 'en')).to eq('/unknown')
      end
    end
  end

  describe '.translate_path' do
    context 'when translating to English' do
      it 'translates recursos to resources' do
        expect(RouterHelper.translate_path('recursos', 'en')).to eq('resources')
      end

      it 'translates servicios to services' do
        expect(RouterHelper.translate_path('servicios', 'en')).to eq('services')
      end

      it 'translates catalogo to catalog' do
        expect(RouterHelper.translate_path('catalogo', 'en')).to eq('catalog')
      end

      it 'translates agenda to schedule' do
        expect(RouterHelper.translate_path('agenda', 'en')).to eq('schedule')
      end

      it 'translates somos to about_us' do
        expect(RouterHelper.translate_path('somos', 'en')).to eq('about_us')
      end

      it 'keeps blog as blog' do
        expect(RouterHelper.translate_path('blog', 'en')).to eq('blog')
      end

      it 'keeps resources as resources' do
        expect(RouterHelper.translate_path('resources', 'en')).to eq('resources')
      end
    end

    context 'when translating to Spanish' do
      it 'translates resources to recursos' do
        expect(RouterHelper.translate_path('resources', 'es')).to eq('recursos')
      end

      it 'translates services to servicios' do
        expect(RouterHelper.translate_path('services', 'es')).to eq('servicios')
      end

      it 'translates catalog to catalogo' do
        expect(RouterHelper.translate_path('catalog', 'es')).to eq('catalogo')
      end

      it 'translates schedule to agenda' do
        expect(RouterHelper.translate_path('schedule', 'es')).to eq('agenda')
      end

      it 'translates about_us to somos' do
        expect(RouterHelper.translate_path('about_us', 'es')).to eq('somos')
      end

      it 'keeps blog as blog' do
        expect(RouterHelper.translate_path('blog', 'es')).to eq('blog')
      end

      it 'keeps recursos as recursos' do
        expect(RouterHelper.translate_path('recursos', 'es')).to eq('recursos')
      end
    end

    context 'when path has no translation' do
      it 'returns the original path' do
        expect(RouterHelper.translate_path('unknown', 'en')).to eq('unknown')
        expect(RouterHelper.translate_path('unknown', 'es')).to eq('unknown')
      end
    end

    context 'when locale is a symbol' do
      it 'works with symbol locale' do
        expect(RouterHelper.translate_path('recursos', :en)).to eq('resources')
        expect(RouterHelper.translate_path('resources', :es)).to eq('recursos')
      end
    end
  end

  describe '.detect_mixed_language' do
    context 'when English locale with Spanish path segments' do
      it 'returns corrected path for /servicios' do
        result = RouterHelper.detect_mixed_language('en', '/servicios')
        expect(result).to eq('/services')
      end

      it 'returns corrected path for /servicios/some-slug' do
        result = RouterHelper.detect_mixed_language('en', '/servicios/some-slug')
        expect(result).to eq('/services/some-slug')
      end

      it 'returns corrected path for /recursos' do
        result = RouterHelper.detect_mixed_language('en', '/recursos')
        expect(result).to eq('/resources')
      end

      it 'returns corrected path for /catalogo' do
        result = RouterHelper.detect_mixed_language('en', '/catalogo')
        expect(result).to eq('/catalog')
      end

      it 'returns corrected path for /agenda' do
        result = RouterHelper.detect_mixed_language('en', '/agenda')
        expect(result).to eq('/schedule')
      end

      it 'returns corrected path for /somos' do
        result = RouterHelper.detect_mixed_language('en', '/somos')
        expect(result).to eq('/about_us')
      end
    end

    context 'when Spanish locale with English path segments' do
      it 'returns corrected path for /services' do
        result = RouterHelper.detect_mixed_language('es', '/services')
        expect(result).to eq('/servicios')
      end

      it 'returns corrected path for /services/some-slug' do
        result = RouterHelper.detect_mixed_language('es', '/services/some-slug')
        expect(result).to eq('/servicios/some-slug')
      end

      it 'returns corrected path for /resources' do
        result = RouterHelper.detect_mixed_language('es', '/resources')
        expect(result).to eq('/recursos')
      end

      it 'returns corrected path for /catalog' do
        result = RouterHelper.detect_mixed_language('es', '/catalog')
        expect(result).to eq('/catalogo')
      end

      it 'returns corrected path for /schedule' do
        result = RouterHelper.detect_mixed_language('es', '/schedule')
        expect(result).to eq('/agenda')
      end

      it 'returns corrected path for /about_us' do
        result = RouterHelper.detect_mixed_language('es', '/about_us')
        expect(result).to eq('/somos')
      end
    end

    context 'when locale and path segments match' do
      it 'returns nil for /en/services' do
        result = RouterHelper.detect_mixed_language('en', '/services')
        expect(result).to be_nil
      end

      it 'returns nil for /es/servicios' do
        result = RouterHelper.detect_mixed_language('es', '/servicios')
        expect(result).to be_nil
      end

      it 'returns nil for /en/resources' do
        result = RouterHelper.detect_mixed_language('en', '/resources')
        expect(result).to be_nil
      end

      it 'returns nil for /es/recursos' do
        result = RouterHelper.detect_mixed_language('es', '/recursos')
        expect(result).to be_nil
      end

      it 'returns nil for /en/schedule' do
        result = RouterHelper.detect_mixed_language('en', '/schedule')
        expect(result).to be_nil
      end

      it 'returns nil for /es/agenda' do
        result = RouterHelper.detect_mixed_language('es', '/agenda')
        expect(result).to be_nil
      end

      it 'returns nil for /en/about_us' do
        result = RouterHelper.detect_mixed_language('en', '/about_us')
        expect(result).to be_nil
      end

      it 'returns nil for /es/somos' do
        result = RouterHelper.detect_mixed_language('es', '/somos')
        expect(result).to be_nil
      end
    end

    context 'when path segment is same in both languages' do
      it 'returns nil for /en/blog' do
        result = RouterHelper.detect_mixed_language('en', '/blog')
        expect(result).to be_nil
      end

      it 'returns nil for /es/blog' do
        result = RouterHelper.detect_mixed_language('es', '/blog')
        expect(result).to be_nil
      end
    end

    context 'edge cases' do
      it 'returns nil for empty path' do
        result = RouterHelper.detect_mixed_language('en', '')
        expect(result).to be_nil
      end

      it 'returns nil for root path' do
        result = RouterHelper.detect_mixed_language('en', '/')
        expect(result).to be_nil
      end

      it 'returns nil for unknown path segment' do
        result = RouterHelper.detect_mixed_language('en', '/unknown-path')
        expect(result).to be_nil
      end

      it 'returns nil for invalid locale' do
        result = RouterHelper.detect_mixed_language('fr', '/servicios')
        expect(result).to be_nil
      end
    end
  end
end
