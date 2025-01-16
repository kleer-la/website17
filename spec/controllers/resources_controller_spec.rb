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
        also_download: []
      )
    end

    it 'redirects old slug to current slug' do
      allow(Resource).to receive(:create_one_keventer)
        .with('old-slug', 'es')
        .and_return(resource)
      
      get '/recursos/old-slug'
      
      expect(last_response).to be_redirect
      expect(last_response.location).to end_with('/recursos/current-slug')
    end
  end
end