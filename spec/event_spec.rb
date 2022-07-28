require 'spec_helper'
require './lib/event_type'
require './lib/event'

describe Event do
  it 'has event type' do
    event = Event.new('sudoku')
    expect(event.event_type).to eq 'sudoku'
  end
end

describe EventFacade do
  it 'empty' do
    event = EventFacade.new
    expect(event.name).to be nil
  end
  it 'has event type' do
    et = EventType.create_null('./spec/event_type_1.xml')
    event = EventFacade.new.from_event_type(et)
    expect(event.name).to eq 'Introducción a Scrum (Módulo 1 - CSD Track)'
  end
end
