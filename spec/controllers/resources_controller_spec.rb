require 'spec_helper'
require './app'

describe 'Resources routes' do
  include Rack::Test::Methods

  def app
    Sinatra::Application.new
  end

  describe 'GET /recursos/:slug' do
    let(:resource) { double('Resource', slug: 'current-slug') }

    before do
      env 'rack.session', { locale: 'es' }

      # Mock minimal required dependencies
      allow_any_instance_of(Sinatra::Application).to receive(:@meta_tags).and_return(double.as_null_object)
      allow_any_instance_of(Sinatra::Application).to receive(:@markdown_renderer).and_return(double(render: ''))
      allow(resource).to receive_messages(
        tabtitle: '',
        seo_description: '',
        cover: '',
        long_description: '',
        also_download: [],
        format: 'pdf',
        landing: '',
        title: 'Test Resource',
        description: 'Test description',
        comments: '',
        getit: '',
        assessment_id: nil,
        preview: '',
        trainers_with_role: [],
        recommended_not_downloads: []
      )
    end

    it 'redirects old slug to current slug' do
      allow(Resource).to receive(:create_one_keventer)
        .with('old-slug', 'es')
        .and_return(resource)

      get '/es/recursos/old-slug'

      expect(last_response).to be_redirect
      expect(last_response.location).to end_with('/recursos/current-slug')
    end

    context 'language switcher alternate route' do
      let(:router_helper) { RouterHelper.instance }
      let(:alternate_resource_with_content) { double('Resource', slug: 'some-slug', title: 'English Title') }
      let(:alternate_resource_empty) { double('Resource', slug: 'some-slug', title: '') }

      before do
        # Reset RouterHelper state between tests
        router_helper.alternate_route = nil

        allow(resource).to receive(:slug).and_return('some-slug')
        allow(resource).to receive(:long_description=)
        allow(Resource).to receive(:create_one_keventer)
          .with('some-slug', 'es')
          .and_return(resource)
      end

      it 'sets alternate route when translation exists' do
        allow(Resource).to receive(:create_one_keventer)
          .with('some-slug', 'en')
          .and_return(alternate_resource_with_content)

        get '/es/recursos/some-slug'

        expect(router_helper.alternate_route).to eq('/resources/some-slug')
      end

      it 'sets alternate route to index when translation has no content' do
        allow(Resource).to receive(:create_one_keventer)
          .with('some-slug', 'en')
          .and_return(alternate_resource_empty)

        get '/es/recursos/some-slug'

        expect(router_helper.alternate_route).to eq('/resources')
      end
    end
  end

  describe 'GET /resources/:slug' do
    let(:resource) { double('Resource', slug: 'current-slug') }

    before do
      env 'rack.session', { locale: 'en' }

      # Mock minimal required dependencies
      allow_any_instance_of(Sinatra::Application).to receive(:@meta_tags).and_return(double.as_null_object)
      allow_any_instance_of(Sinatra::Application).to receive(:@markdown_renderer).and_return(double(render: ''))
      allow(resource).to receive_messages(
        tabtitle: '',
        seo_description: '',
        cover: '',
        long_description: '',
        also_download: [],
        format: 'pdf',
        landing: '',
        title: 'Test Resource',
        description: 'Test description',
        comments: '',
        getit: '',
        assessment_id: nil,
        preview: '',
        trainers_with_role: [],
        recommended_not_downloads: []
      )
    end

    context 'language switcher alternate route' do
      let(:router_helper) { RouterHelper.instance }
      let(:alternate_resource_with_content) { double('Resource', slug: 'some-slug', title: 'Spanish Title') }
      let(:alternate_resource_empty) { double('Resource', slug: 'some-slug', title: '') }

      before do
        # Reset RouterHelper state between tests
        router_helper.alternate_route = nil

        allow(resource).to receive(:slug).and_return('some-slug')
        allow(resource).to receive(:long_description=)
        allow(Resource).to receive(:create_one_keventer)
          .with('some-slug', 'en')
          .and_return(resource)
      end

      it 'sets alternate route when Spanish translation exists' do
        allow(Resource).to receive(:create_one_keventer)
          .with('some-slug', 'es')
          .and_return(alternate_resource_with_content)

        get '/en/resources/some-slug'

        expect(router_helper.alternate_route).to eq('/recursos/some-slug')
      end

      it 'sets alternate route to index when Spanish translation has no content' do
        allow(Resource).to receive(:create_one_keventer)
          .with('some-slug', 'es')
          .and_return(alternate_resource_empty)

        get '/en/resources/some-slug'

        expect(router_helper.alternate_route).to eq('/recursos')
      end
    end
  end
end