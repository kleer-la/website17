require_relative '../../spec_helper'
require './lib/models/recommended'

RSpec.describe RecommendedPage do
  let(:page_data) do
    {
      'type' => 'page',
      'title' => 'Membresía IA',
      'subtitle' => 'La membresía para adoptar IA',
      'slug' => 'membresia-ia',
      'lang' => 'es'
    }
  end

  it 'is built for the page type, which used to be dropped in silence' do
    expect(Recommended.create(page_data)).to be_a(RecommendedPage)
  end

  it 'links to the flagship route: the slug is the whole path' do
    expect(Recommended.create(page_data).url).to eq('/es/membresia-ia')
  end

  it 'keeps each language on its own record, with its own slug' do
    english = Recommended.create(page_data.merge('lang' => 'en', 'slug' => 'ai-membership'))

    expect(english.url).to eq('/en/ai-membership')
  end

  it 'carries the title and subtitle the card shows' do
    recommended = Recommended.create(page_data)

    expect(recommended.title).to eq('Membresía IA')
    expect(recommended.subtitle).to eq('La membresía para adoptar IA')
  end
end
