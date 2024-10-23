require './controllers/helper'

class TestHelper
  include Helpers
end

describe 'helpers' do
  let(:helpers) { TestHelper.new }
  it 'Sanitize URL' do
    expect(helpers.url_sanitize('áéíóúÁËÍÖÜ')).to eq 'aeiouAEIOU'
  end
end

describe '#extract_titles' do
  let(:helpers) { TestHelper.new }
  context 'with no titles' do
    it 'returns an empty array when content has no h2 tags' do
      rendered_html = 'Just regular content without headers'
      expect(helpers.extract_titles(rendered_html)).to eq([])
    end
  end

  context 'with h2 titles only' do
    it 'extracts h2 titles' do
      rendered_html = <<~HTML
        <h2>First Title</h2>
        Some content
        <h2>Second Title</h2>
        More content
      HTML

      expected = [
        { title: 'First Title', subtitles: [] },
        { title: 'Second Title', subtitles: [] }
      ]

      expect(helpers.extract_titles(rendered_html)).to eq(expected)
    end
  end

  context 'with h2 and h3 titles' do
    it 'extracts h2 titles and their corresponding h3 subtitles' do
      rendered_html = <<~HTML
        <h2>Main Title</h2>
        <h3>First Subtitle</h3>
        Some content
        <h3>Second Subtitle</h3>
        More content
      HTML

      expected = [
        {
          title: 'Main Title',
          subtitles: ['First Subtitle', 'Second Subtitle']
        }
      ]

      expect(helpers.extract_titles(rendered_html)).to eq(expected)
    end
  end

  context 'with multiple h2 sections and their h3 subtitles' do
    it 'extracts multiple sections with their respective subtitles' do
      rendered_html = <<~HTML
        <h2>First Section</h2>
        <h3>Subtitle 1.1</h3>
        <h3>Subtitle 1.2</h3>
        <h2>Second Section</h2>
        <h3>Subtitle 2.1</h3>
      HTML

      expected = [
        {
          title: 'First Section',
          subtitles: ['Subtitle 1.1', 'Subtitle 1.2']
        },
        {
          title: 'Second Section',
          subtitles: ['Subtitle 2.1']
        }
      ]

      expect(helpers.extract_titles(rendered_html)).to eq(expected)
    end
  end

  context 'with HTML tags within titles' do
    it 'preserves HTML tags in titles and subtitles' do
      rendered_html = <<~HTML
        <h2>Title with <strong>bold</strong> text</h2>
        Content
        <h3>Subtitle with <em>italic</em></h3>
        More content
      HTML

      expected = [
        {
          title: 'Title with <strong>bold</strong> text',
          subtitles: ['Subtitle with <em>italic</em>']
        }
      ]

      expect(helpers.extract_titles(rendered_html)).to eq(expected)
    end
  end

  context 'with content between titles' do
    it 'ignores non-header content' do
      rendered_html = <<~HTML
        <div>Initial content</div>
        <h2>First Title</h2>
        <p>Some paragraph</p>
        <div>Some div content</div>
        <h3>A Subtitle</h3>
        <span>More content</span>
      HTML

      expected = [
        {
          title: 'First Title',
          subtitles: ['A Subtitle']
        }
      ]

      expect(helpers.extract_titles(rendered_html)).to eq(expected)
    end
  end

  context 'with nested content' do
    it 'handles nested HTML structures' do
      rendered_html = <<~HTML
        <h2>Main Title</h2>
        <div class="content">
          <p>Nested content</p>
          <h3>Nested Subtitle</h3>
          <div>
            <p>Deeply nested content</p>
          </div>
        </div>
      HTML

      expected = [
        {
          title: 'Main Title',
          subtitles: ['Nested Subtitle']
        }
      ]

      expect(helpers.extract_titles(rendered_html)).to eq(expected)
    end
  end
end
