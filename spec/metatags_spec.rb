require './lib/metatags'
include MetaTags

describe 'metatags' do
  context 'robot' do
    it 'add noindex' do
      meta_tags! noindex: true
      expect(display_meta_tags).to include '<meta name="robots" content="noindex"/>'
    end
    it 'noindex false' do
      meta_tags! noindex: false
      expect(display_meta_tags).not_to include '<meta name="robots" content='
    end
    it 'add nofollow' do
      meta_tags! nofollow: true
      expect(display_meta_tags).to include '<meta name="robots" content="nofollow"/>'
    end
    it 'add noarchive' do
      meta_tags! noarchive: true
      expect(display_meta_tags).to include '<meta name="robots" content="noarchive"/>'
    end
  end
  context 'default' do
    it 'noindex nofollow false' do
      head = display_meta_tags
      expect(head).not_to include 'noindex'
      expect(head).not_to include 'nofollow'
    end
    it 'one time' do
      meta_tags! nofollow: true
      display_meta_tags
      expect(display_meta_tags).not_to include '<meta name="robots" content='
    end
    it 'charset' do
      expect(display_meta_tags).to include '<meta charset="utf-8">'
    end
  end
  context 'title' do
    it 'no title, no meta' do
      head = display_meta_tags
      expect(head).not_to include '<meta property="og:title"'
      expect(head).not_to include '<title>'
    end

    it 'title -> OG & title (no site)' do
      head = display_meta_tags title: 'Sarambanga'
      expect(head).to include '<meta property="og:title" content="Sarambanga"/>'
      expect(head).to include '<title>Sarambanga</title>'
    end
    it 'title -> OG & title (w site)' do
      head = display_meta_tags title: 'Sarambanga', site: 'Pepe'
      expect(head).to include '<meta property="og:title" content="Sarambanga"/>'
      expect(head).to include '<title>Pepe | Sarambanga</title>'
    end
  end
  context 'description' do
    it 'no description, no meta' do
      head = display_meta_tags
      expect(head).not_to include '<meta property="og:description"'
      expect(head).not_to include '<meta name="description"'
    end

    it 'description -> OG & description' do
      head = display_meta_tags description: 'Sarambanga'
      expect(head).to include '<meta property="og:description" content="Sarambanga"/>'
      expect(head).to include '<meta name="description" content="Sarambanga"/>'
    end
  end
  context 'canonical' do
    it 'has not canonical' do
      head = display_meta_tags base_url: 'https://www.kleer.la', charset: '', 'http-equiv': nil, viewport: nil
      expect(head).to eq ''
    end
    it 'has canonical' do
      head = display_meta_tags base_url: 'https://www.kleer.la', canonical: 'randanganga'
      expect(head).to include '<link rel="canonical" href="https://www.kleer.la/randanganga"/>'
    end
  end
  context 'http-equiv' do
    it 'defaukt has http-equiv' do
      head = display_meta_tags
      expect(head).to include 'http-equiv='
    end
    it 'has not http-equiv' do
      head = display_meta_tags 'http-equiv': nil
      expect(head).not_to include 'http-equiv='
    end
    it 'has http-equiv' do
      head = display_meta_tags
      expect(head).to include 'http-equiv="X-UA-Compatible'
      expect(head).to include 'content="IE=edge"'
    end
  end
end
