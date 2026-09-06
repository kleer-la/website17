require 'spec_helper'
require './lib/event_type'

describe EventType do
  context 'Load event from JSON' do
    before(:each) do
      EventType.null_json_api(NullJsonAPI.new('./spec/mocks/updated_event_type.json'))
      @event_type = EventType.create_keventer_json('1')
    end

    it 'has name' do
      expect(@event_type.id).to eq 1
      expect(@event_type.name).to eq 'Curso actualizado'
    end

    it 'has seo_title' do
      expect(@event_type.seo_title).to eq 'Curso Actualizado - El mejor curso SEO optimizado'
    end

    it 'has category' do
      expect(@event_type.categories.count).to eq 1
      expect(@event_type.categories[0]).to eq 'Desarrollo Profesional'
    end

    it 'has next events' do
      expect(@event_type.public_editions.count).to eq 1
    end
  end

  context 'SEO title handling' do
    it 'returns nil when seo_title is not present' do
      event_type = EventType.new({ 'id' => '2', 'name' => 'Test Course', 'slug' => '2-test-course' })
      expect(event_type.seo_title).to be_nil
    end

    it 'loads seo_title from JSON when present' do
      EventType.null_json_api(NullJsonAPI.new('./spec/mocks/updated_event_type.json'))
      event_type = EventType.create_keventer_json('1')
      expect(event_type.seo_title).to eq 'Curso Actualizado - El mejor curso SEO optimizado'
    end
  end

  context 'Redirect' do
    before(:each) do
      @slug = '4-enterprise-agility'
      @event_type = EventType.new({ 'id' => '4', 'slug' => @slug })
      # "canonical_slug": "418-enterprise-agility-practitioner",
    end
    it 'dont redirect' do
      expect(@event_type.redirect_to(@slug)).to be nil
    end
    it 'redirect to itself' do
      expect(@event_type.redirect_to('4-Enterprise-Agility')).to include @slug
    end
    it 'redirect to canonical' do
      @event_type.canonical_slug = '4-FTW'
      @event_type.deleted = true

      expect(@event_type.redirect_to('4-Enterprise-Agility')).to include '4-FTW'
    end
    it 'deleted & canonical to itself - adk' do
      @event_type.canonical_slug = @slug
      @event_type.deleted = true

      expect(@event_type.redirect_to('4-Enterprise-Agility')).to eq ''
    end
    it 'deleted & canonical to empty - adk' do
      @event_type.canonical_slug = ''
      @event_type.deleted = true

      expect(@event_type.redirect_to('4-Enterprise-Agility')).to eq ''
    end
    it 'redirect to external link' do
      @event_type.external_site_url = '/services'
      @event_type.canonical_slug = '4-FTW'
      @event_type.deleted = true

      expect(@event_type.redirect_to('4-Enterprise-Agility')).to eq '/services'
    end
  end

  # A 301 is how a retired course hands its authority to the one that replaced
  # it. Landing on the language-less namespace — which answers 200 and then
  # names /es/... as its canonical — spends the signal on a page that says it
  # is not the right one.
  context 'Redirect destination' do
    def deleted_course(lang:)
      EventType.new({ 'id' => '4', 'slug' => '4-enterprise-agility', 'lang' => lang })
               .tap do |et|
        et.canonical_slug = '418-enterprise-agility-practitioner'
        et.deleted = true
      end
    end

    it 'sends a Spanish course to the Spanish course URL' do
      expect(deleted_course(lang: 'es').redirect_to('4-enterprise-agility'))
        .to eq '/es/cursos/418-enterprise-agility-practitioner'
    end

    it 'sends an English course to the English course URL' do
      expect(deleted_course(lang: 'en').redirect_to('4-enterprise-agility'))
        .to eq '/en/courses/418-enterprise-agility-practitioner'
    end

    it 'assumes Spanish when the course does not say' do
      expect(deleted_course(lang: nil).redirect_to('4-enterprise-agility'))
        .to eq '/es/cursos/418-enterprise-agility-practitioner'
    end
  end

  # The canonical tag is built by Metatags, which prepends the base URL and the
  # language itself. This path has to stay relative to the language or the tag
  # comes out as /es/es/cursos/... — which is why the redirect needs its own
  # method instead of this one growing a prefix.
  context 'Canonical path' do
    it 'stays relative to the language' do
      event_type = EventType.new({ 'id' => '4', 'slug' => '4-enterprise-agility', 'lang' => 'es' })
      event_type.canonical_slug = '418-enterprise-agility-practitioner'

      expect(event_type.canonical_url).to eq '/cursos/418-enterprise-agility-practitioner'
    end
  end

  context 'Own path' do
    it 'names the language even when the course does not' do
      event_type = EventType.new({ 'id' => '4', 'slug' => '4-enterprise-agility' })

      expect(event_type.uri_path).to eq '/es/cursos/4-enterprise-agility'
    end
  end
end
