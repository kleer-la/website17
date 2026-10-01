require 'spec_helper'
require './app'
require 'json'
require 'nokogiri'

# The card shows the whole description: Keventer caps it at 220 characters, and
# the card grows to fit it, its row stretching to the tallest one (index.scss).
# Before, a 25-word cut still left text past the fixed card height, and a
# 27-word one ended "colaboración ...".
describe 'the card of a resource in the listing' do
  include Rack::Test::Methods

  def app
    Sinatra::Application.new
  end

  let(:description) do
    'Un prompt práctico que te ayuda a comunicarte de forma clara y empática en cualquier situación, usando ' \
      'herramientas de coaching, comunicación no violenta y colaboración en equipos.'
  end

  before do
    doc = JSON.parse(File.read('./spec/fixtures/resource_concepts.json'))
    doc = doc.merge('slug' => 'prompt-comunicar', 'format' => 'guide', 'description_es' => description)
    allow(Page).to receive(:load_from_keventer).and_return(Page.new)
    allow(Resource).to receive(:create_list_keventer).and_return(Resource.load_list([doc.merge('title_en' => '')]))
  end

  it 'shows the whole description' do
    get '/es/recursos'

    card = Nokogiri::HTML(last_response.body).at_css('#prompt-comunicar .card-text')
    expect(card.text).to eq(description)
  end
end
