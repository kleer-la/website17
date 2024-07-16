require 'spec_helper'
require './lib/models/recommended'

RSpec.describe Recommended do
  let(:doc) do
    {
      'title' => 'Test Title',
      'subtitle' => 'Test Subtitle',
      'slug' => 'test-slug',
      'cover' => 'test-cover.jpg',
      'type' => 'article'
    }
  end

  describe '.create' do
    context 'when type is article' do
      it 'returns a RecommendedArticle instance' do
        expect(Recommended.create(doc)).to be_a(RecommendedArticle)
      end
    end

    context 'when type is event_type' do
      let(:doc) { super().merge('type' => 'event_type') }

      it 'returns a RecommendedEventType instance' do
        expect(Recommended.create(doc)).to be_a(RecommendedEventType)
      end
    end

    context 'when type is service' do
      let(:doc) { super().merge('type' => 'service') }

      it 'returns a RecommendedService instance' do
        expect(Recommended.create(doc)).to be_a(RecommendedService)
      end
    end

    context 'when type is unknown' do
      let(:doc) { super().merge('type' => 'unknown') }

      it 'raises an ArgumentError' do
        expect { Recommended.create(doc) }.to raise_error(ArgumentError, 'Unknown recommendation type: unknown')
      end
    end
  end

  describe '#initialize' do
    subject { Recommended.new(doc) }

    it 'sets the attributes correctly' do
      expect(subject.title).to eq('Test Title')
      expect(subject.subtitle).to eq('Test Subtitle')
      expect(subject.slug).to eq('test-slug')
      expect(subject.cover).to eq('test-cover.jpg')
      expect(subject.type).to eq('article')
    end
  end

  describe '#url' do
    subject { Recommended.new(doc) }

    it 'raises NotImplementedError' do
      expect { subject.url }.to raise_error(NotImplementedError, "Recommended must implement the 'url' method")
    end
  end
end

RSpec.describe RecommendedArticle do
  let(:doc) do
    {
      'title' => 'Article Title',
      'subtitle' => 'Article Subtitle',
      'slug' => 'article-slug',
      'cover' => 'article-cover.jpg',
      'type' => 'article'
    }
  end

  subject { RecommendedArticle.new(doc) }

  it 'returns the correct URL for an article' do
    expect(subject.url).to eq('/es/blog/article-slug')
  end
end

RSpec.describe RecommendedEventType do
  let(:doc) do
    {
      'title' => 'Event Type Title',
      'subtitle' => 'Event Type Subtitle',
      'slug' => 'event-type-slug',
      'cover' => 'event-type-cover.jpg',
      'type' => 'event_type'
    }
  end

  subject { RecommendedEventType.new(doc) }

  it 'url returns a URL from the slug' do
    expect(subject.url).to eq('/es/cursos/event-type-slug')
  end
  it 'url returns a external URL when provided ' do
    event_type = RecommendedEventType.new(
      doc.merge('external_url' => 'https://academia.kleer.la/event')
    )
    expect(event_type.url).to eq('https://academia.kleer.la/event')
  end
end

RSpec.describe RecommendedService do
  let(:doc) do
    {
      'title' => 'Service Title',
      'subtitle' => 'Service Subtitle',
      'slug' => 'service-slug',
      'cover' => 'service-cover.jpg',
      'type' => 'service'
    }
  end

  subject { RecommendedService.new(doc) }

  it 'returns the correct URL for a service' do
    expect(subject.url).to eq('/es/servicios/service-slug')
  end
end
