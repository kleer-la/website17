require 'spec_helper'
require './app'
require 'nokogiri'

# Under the tagline, the footer says in two lines what Kleer does and for whom
# (#472). Plain text, not a heading: the footer adds nothing to the outline (#466).
describe 'the footer descriptor' do
  def app
    Sinatra::Application.new
  end

  before do
    allow(Page).to receive(:load_from_keventer).and_return(Page.new)
  end

  def footer(lang)
    get "/#{lang}/"
    Nokogiri::HTML(last_response.body).at_css('footer')
  end

  {
    'es' => ['Cambio organizacional, producto digital y adopción de IA.',
             'Consultoría y formación in-company en Latinoamérica.'],
    'en' => ['Organizational change, digital product and AI adoption.',
             'Consulting and in-company training in Latin America.']
  }.each do |lang, lines|
    it "shows its two lines under the tagline in #{lang}" do
      descriptor = footer(lang).at_css('.footer__tagline + p.footer__descriptor')

      expect(descriptor).not_to be_nil
      expect(descriptor.inner_html.split(%r{<br\s*/?>}).map(&:strip)).to eq(lines)
    end
  end

  it 'is not a heading' do
    expect(footer('es').css('h1, h2, h3, h4, h5, h6').map(&:text).join).not_to include('Consultoría')
  end

  it 'renders nothing when the text is empty' do
    allow(I18n).to receive(:t).and_call_original
    allow(I18n).to receive(:t).with('generals.descriptor', hash_including(default: '')).and_return('')

    expect(footer('es').at_css('.footer__descriptor')).to be_nil
  end
end
