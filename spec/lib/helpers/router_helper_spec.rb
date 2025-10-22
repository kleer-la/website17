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
    it 'returns current route when alternate is not set' do
      router_helper.set_current_route('/es/recursos')
      expect(router_helper.get_alternate_route).to eq('/recursos')
    end

    it 'returns alternate route when set' do
      router_helper.set_current_route('/es/recursos')
      router_helper.alternate_route = '/resources/some-slug'
      expect(router_helper.get_alternate_route).to eq('/resources/some-slug')
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
