require 'spec_helper'
require './app'

# The flagship catch-all (get '/:slug') must not forward garbage paths to the
# Keventer API: scrapers request quoted strings from our HTML (aria-labels,
# CSS classes) as URLs, and URI.join raises URI::InvalidURIError on them,
# turning what should be a 404 into a 500.
describe "GET /:slug (flagship catch-all)" do
  def app
    Sinatra::Application.new
  end

  context 'with a non-slug path (bot-extracted attribute text)' do
    it 'returns 404, not 500, for a path with spaces' do
      get '/Contact%20us%20via%20WhatsApp'
      expect(last_response.status).to eq(404)
    end

    it 'returns 404, not 500, for CSS-class-like paths' do
      get '/col-lg-6%20contact__img-container'
      expect(last_response.status).to eq(404)
    end

    it 'does not hit the Keventer API for garbage slugs' do
      expect(Page).not_to receive(:load_from_keventer)
      get '/mb-3%20contact-only-field'
    end
  end

  context 'with a well-formed slug' do
    it 'still consults Page.load_from_keventer' do
      page = instance_double(Page, flagship?: false)
      expect(Page).to receive(:load_from_keventer).with(anything, 'some-page').and_return(page)
      get '/some-page'
      expect(last_response.status).to eq(404) # non-flagship falls through
    end
  end
end
