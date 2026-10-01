require 'spec_helper'
require './app'
require 'json'

# [[slug]] and [[slug|texto]] in the text of a card link to another card of the
# resource; everything else stays escaped (#433, validated in kleer-la/eventer#226).
describe ConceptLinkHelper do
  include ConceptLinkHelper

  let(:resource) { Resource.new(JSON.parse(File.read('./spec/fixtures/resource_concepts.json')), 'es') }
  let(:token) { resource.concept('token') }
  let(:base) { '/es/recursos/conceptos-de-ia' }

  def html(text) = concept_text_html(resource, token, text, base)

  it 'links [[slug]] to the card, showing its name' do
    expect(html('Lo aprende de los [[datos]].'))
      .to eq('Lo aprende de los <a class="concepts-link" href="/es/recursos/conceptos-de-ia/datos">' \
             'Datos de entrenamiento</a>.')
  end

  it 'links [[slug|texto]] showing the text' do
    expect(html('Varios [[ modelo | modelos ]].'))
      .to eq('Varios <a class="concepts-link" href="/es/recursos/conceptos-de-ia/modelo">modelos</a>.')
  end

  it 'shows only the text for a slug that is not a card, without brackets' do
    expect(html('Un [[nada|arnés]] y un [[tampoco]].')).to eq('Un arnés y un tampoco.')
  end

  it 'does not link the card to itself' do
    expect(html('Cada [[token|token]] cuenta.')).to eq('Cada token cuenta.')
  end

  it 'keeps the rest of the text escaped, the link text too' do
    expect(html('<b>x</b> & [[datos|<i>y</i>]]'))
      .to eq('&lt;b&gt;x&lt;/b&gt; &amp; <a class="concepts-link" href="/es/recursos/conceptos-de-ia/datos">' \
             '&lt;i&gt;y&lt;/i&gt;</a>')
  end

  it 'reads the marks as plain text where no link fits' do
    expect(concept_plain_text(resource, 'De los [[datos]] y sus [[modelo|modelos]], [[nada]].'))
      .to eq('De los Datos de entrenamiento y sus modelos, nada.')
  end
end
