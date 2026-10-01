require './lib/models/resources'
require 'spec_helper'
require 'json'

describe 'Resource of the concepts format' do
  let(:doc) { JSON.parse(File.read('./spec/fixtures/resource_concepts.json')) }
  let(:resource) { Resource.new(doc, 'es') }

  it 'knows it is a concepts resource' do
    expect(resource.concepts?).to be true
    expect(Resource.new(doc.merge('format' => 'card'), 'es').concepts?).to be false
  end

  it 'reads the concepts in their order, with every field' do
    expect(resource.concepts.map(&:slug)).to eq(%w[datos modelo token agente])

    token = resource.concept('token')
    expect(token.name).to eq('Token')
    expect(token.question).to eq('¿Qué es un token?')
    expect(token.stage).to eq('Qué pasa cuando le escribís')
    expect(token.definition).to eq('La unidad en que el modelo lee y escribe.')
    expect(token.analogy).to eq('Analogía de Token.')
    expect(token.misconception).to eq('Malentendido de Token.')
    expect(token.correction).to eq('Corrección de Token.')
    expect(token.practice).to eq('Práctica de Token.')
    expect(token.media).to include('class="toks"')
    expect(token.related_slugs).to eq(%w[modelo fantasma])
    expect(token.updated_at).to eq('2026-09-15T10:00:00.000Z')
  end

  it 'groups the concepts by stage, stages in the order of their first concept' do
    doc['concepts'].reverse!

    stages = resource.stages

    expect(stages.map(&:name)).to eq(['Cómo se fabrica', 'Qué pasa cuando le escribís', 'Cómo se pone a trabajar'])
    expect(stages.map(&:number)).to eq([1, 2, 3])
    expect(stages.first.concepts.map(&:slug)).to eq(%w[datos modelo])
    expect(resource.concepts.map(&:slug)).to eq(%w[datos modelo token agente])
  end

  it 'tells where a concept sits and its neighbours' do
    token = resource.concept('token')

    expect(resource.concept_position(token)).to eq(3)
    expect(resource.previous_concept(token).slug).to eq('modelo')
    expect(resource.next_concept(token).slug).to eq('agente')
    expect(resource.previous_concept(resource.concept('datos'))).to be_nil
    expect(resource.next_concept(resource.concept('agente'))).to be_nil
    expect(resource.stage_of(token).number).to eq(2)
  end

  it 'offers as related only the concepts that exist' do
    expect(resource.related_concepts(resource.concept('token')).map(&:slug)).to eq(%w[modelo])
  end

  it 'answers nil for a concept it does not have' do
    expect(resource.concept('nada')).to be_nil
  end

  it 'has no concepts when the API sends none' do
    doc.delete('concepts')

    expect(resource.concepts).to eq([])
    expect(resource.stages).to eq([])
  end

  it 'keeps, from a listing, only the concepts of its language' do
    listing = doc.merge('title_en' => 'AI concepts',
                        'concepts' => [{ 'slug' => 'token', 'lang' => 'es', 'updated_at' => '2026-10-01' },
                                       { 'slug' => 'token-en', 'lang' => 'en', 'updated_at' => '2026-10-02' }])

    es, en = Resource.load_list([listing])

    expect(es.concepts.map(&:slug)).to eq(%w[token])
    expect(en.concepts.map(&:slug)).to eq(%w[token-en])
  end
end
