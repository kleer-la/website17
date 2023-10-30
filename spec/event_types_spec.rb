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
    it 'has subtitle' do
      @event_type = EventType.new(nil, {'subtitle'=> 'One subtitle' } )
      expect(@event_type.subtitle).to eq 'One subtitle'
    end
    it 'has next_events' do
      @event_type = EventType.new(nil, 
        {"next_events" => [
          {"id": 2505,
          "date" => "2023-11-06",
          "place" => "Oficinas de GIRE",
          "city" => "Buenos Aires",
          "country_id" => 9,
          "list_price" => "408000.0",
          "eb_price" => "387600. =>",
          "eb_end_date" => "2023-10-27",
          "registration_link" => "",
          "is_sold_out" => false,
          "duration" => 16,
          "start_time" => "2000-01-01T09:00:00.000Z",
          "end_time" => "2000-01-01T18:00:00.000Z",
          "time_zone_name" => "",
          "currency_iso_code" => "ARS",
          "address" => "Av. Caseros 3572",
          "finish_date" => "2023-11-07",
          "trainers" => []
          } ] }
        
       )
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
