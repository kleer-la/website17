require 'spec_helper'
require './app'

# The card is a fixed-height box. Its description is rendered markdown, which
# brings its own <p>; inside a <p class="card-text"> that closes the outer one,
# and author and date end up outside the card.
describe 'blog list cards' do
  def app
    Sinatra::Application.new
  end

  let(:article) do
    double('article', slug: 'capacitaciones', title: 'Capacitaciones que transforman',
                      description: "Primer párrafo.\n\nSegundo párrafo, más largo.",
                      cover: '/img/x.png', category_name: 'Equipos', lang: 'es', selected: false,
                      trainers: ['Juan Gabardini'], substantive_change_at: '2025-09-30T10:00:00Z',
                      noindex: false, tabtitle: 'x', categories: [])
  end

  before do
    allow(Page).to receive(:load_from_keventer).and_return(Page.new)
    allow(Article).to receive(:create_list_keventer).and_return([article])
    allow(Category).to receive(:create_keventer_json).and_return([])
  end

  it 'keeps the description in a div that holds its paragraphs' do
    get '/es/blog'

    expect(last_response.body).not_to include('<p class="card-text">')
    expect(last_response.body).to match(%r{<div class="card-text">\s*<p>Primer párrafo\.</p>\s*<p>Segundo})
  end
end
