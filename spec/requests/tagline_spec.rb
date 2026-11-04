require 'spec_helper'
require './app'
require 'nokogiri'

# Kleer's tagline sits above the home hero title and in the footer of every page.
describe 'the Kleer tagline' do
  def app
    Sinatra::Application.new
  end

  before do
    allow(Page).to receive(:load_from_keventer).and_return(Page.new)
  end

  { 'es' => 'Decidir. Construir. Sostener.', 'en' => 'Decide. Build. Sustain.' }.each do |lang, tagline|
    context "in #{lang}" do
      let(:html) do
        get "/#{lang}/"
        Nokogiri::HTML(last_response.body)
      end

      it 'opens the home hero' do
        expect(html.at_css('#hero2 .hero__tagline')&.text&.strip).to eq(tagline)
      end

      it 'is in the footer' do
        expect(html.at_css('footer .footer__tagline')&.text&.strip).to eq(tagline)
      end
    end
  end
end
