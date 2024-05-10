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

    it 'has category' do
      expect(@event_type.categories.count).to eq 1
      expect(@event_type.categories[0]).to eq 'Desarrollo Profesional'
    end

    it 'has next events' do
      expect(@event_type.public_editions.count).to eq 1
    end
  end


  context 'Redirect' do
    before(:each) do
      @slug = '4-enterprise-agility'
      @event_type = EventType.new(nil, {'id' => '4', 'slug' => @slug} )
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
    
  end
end
