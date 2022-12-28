require 'spec_helper'
require './lib/event_type'

describe EventType do
  context 'Null Infra' do
    before(:each) do
      @event_type = EventType.create_null('./spec/event_type_1.xml')
    end
    it 'has name' do
      expect(@event_type.id).to eq 4
      expect(@event_type.name).to eq 'Introducción a Scrum (Módulo 1 - CSD Track)'
    end

    it 'has category' do
      expect(@event_type.categories.count).to eq 1
      expect(@event_type.categories[0][1]).to eq 'organizaciones'
    end
  end
  context 'Keventer Infra' do
    before(:each) do
      @event_type = EventType.create_keventer('4')
    end
    it 'has name' do
      expect(@event_type.id).to eq 4
      expect(@event_type.name).to eq 'Introducción a Scrum (Módulo 1 - CSD Track)'
    end

    it 'has category' do
      expect(@event_type.categories.count).to eq 1
      expect(@event_type.categories[0][1]).to eq 'organizaciones'
    end
  end
  context 'JSON' do
    before(:each) do
      @event_type = EventType.new(nil, {'subtitle'=> 'One subtitle' } )
    end
    it 'has subtitle' do
      expect(@event_type.subtitle).to eq 'One subtitle'
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
    it 'deleted & cannonical to itself - adk' do
      @event_type.canonical_slug = @slug
      @event_type.deleted = true

      expect(@event_type.redirect_to('4-Enterprise-Agility')).to eq ''
    end
    it 'deleted & cannonical to empty - adk' do
      @event_type.canonical_slug = ''
      @event_type.deleted = true

      expect(@event_type.redirect_to('4-Enterprise-Agility')).to eq ''
    end
    
  end
end
