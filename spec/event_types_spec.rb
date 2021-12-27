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

    it 'has caegory' do
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

    it 'has caegory' do
      expect(@event_type.categories.count).to eq 1
      expect(@event_type.categories[0][1]).to eq 'organizaciones'
    end
  end
end
