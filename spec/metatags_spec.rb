require './lib/metatags'
include MetaTags

describe 'metatags' do
  context 'robot' do
    before(:each) do
      @metatags = Tags.new
    end
    it 'add noindex' do
      @metatags.set! noindex: true
      expect(@metatags.display).to include '<meta name="robots" content="noindex"/>'
    end
    it 'noindex false' do
      @metatags.set! noindex: false
      expect(@metatags.display).not_to include '<meta name="robots" content='
    end
    it 'add nofollow' do
      @metatags.set! nofollow: true
      expect(@metatags.display).to include '<meta name="robots" content="nofollow"/>'
    end
    it 'add noarchive' do
      @metatags.set! noarchive: true
      expect(@metatags.display).to include '<meta name="robots" content="noarchive"/>'
    end
  end
  context 'default' do
    it 'noindex nofollow false' do
      head = Tags.new.display
      expect(head).not_to include 'noindex'
      expect(head).not_to include 'nofollow'
    end
    it 'one time' do
      meta_tags = Tags.new
      meta_tags.set! nofollow: true
      meta_tags.display
      expect(meta_tags.display).not_to include '<meta name="robots" content='
    end
    it 'charset' do
      expect(Tags.new.display).to include '<meta charset="utf-8">'
    end
  end
  context 'title' do
    it 'no title, no meta' do
      head = Tags.new.display
      expect(head).not_to include '<meta property="og:title"'
      expect(head).not_to include '<title>'
    end

    it 'title -> OG & title (no site)' do
      head = Tags.new.display title: 'Sarambanga'
      expect(head).to include '<meta property="og:title" content="Sarambanga"/>'
      expect(head).to include '<title>Sarambanga</title>'
    end
    it 'title -> OG & title (w site)' do
      head = Tags.new.display title: 'Sarambanga', site: 'Pepe'
      expect(head).to include '<meta property="og:title" content="Sarambanga"/>'
      expect(head).to include '<title>Pepe | Sarambanga</title>'
    end
  end
  context 'description' do
    it 'no description, no meta' do
      head = Tags.new.display
      expect(head).not_to include '<meta property="og:description"'
      expect(head).not_to include '<meta name="description"'
    end

    it 'description -> OG & description' do
      head = Tags.new.display description: 'Sarambanga'
      expect(head).to include '<meta property="og:description" content="Sarambanga"/>'
      expect(head).to include '<meta name="description" content="Sarambanga"/>'
    end
  end
  context 'canonical' do
    it 'has not canonical' do
      head = Tags.new.display base_url: 'https://www.kleer.la', charset: '', 'http-equiv': nil, viewport: nil, hreflang: []
      expect(head).to eq ''
    end
    it 'has canonical' do
      head = Tags.new.display base_url: 'https://www.kleer.la', canonical: 'randanganga'
      expect(head).to include '<link rel="canonical" href="https://www.kleer.la/randanganga"/>'
    end
  end
  context 'http-equiv' do
    it 'default has http-equiv' do
      head = Tags.new.display
      expect(head).to include 'http-equiv='
    end
    it 'has not http-equiv' do
      head = Tags.new.display 'http-equiv': nil
      expect(head).not_to include 'http-equiv='
    end
    it 'has http-equiv' do
      head = Tags.new.display
      expect(head).to include 'http-equiv="X-UA-Compatible'
      expect(head).to include 'content="IE=edge"'
    end
  end
  context 'hreflang' do
    it 'default has hreflang' do
      head = Tags.new.display 'path': ''
      expect(head).to include 'rel="alternate" hreflang='
    end
    it 'default has en & es' do
      head = Tags.new.display 'path': ''
      expect(head).to include 'rel="alternate" hreflang="en"'
      expect(head).to include 'rel="alternate" hreflang="es"'
    end
    it 'href is base/lang/path' do
      head = Tags.new.display 'path': '/sambayon'
      expect(head).to include 'href="https://kleer.la/es/sambayon"'
      expect(head).to include 'href="https://kleer.la/en/sambayon"'
    end
    it 'dont include hreflang if no lang' do
      head = Tags.new.display 'path': '/sambayon', hreflang: []
      expect(head).not_to include 'href="https://kleer.la/es/sambayon"'
      expect(head).not_to include 'href="https://kleer.la/en/sambayon"'
    end
    it 'dont include hreflang if no path' do
      head = Tags.new.display 'path': nil
      expect(head).not_to include 'href="https://kleer.la/es"'
      expect(head).not_to include 'href="https://kleer.la/en"'
    end
    # it 'dont include hreflang if canonical' do
    #   head = Tags.new.display 'path': '', canonical: 'pepe'
    #   expect(head).not_to include 'href="https://kleer.la/es"'
    #   expect(head).not_to include 'href="https://kleer.la/en"'
    # end
  end
end
