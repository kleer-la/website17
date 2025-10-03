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
end
