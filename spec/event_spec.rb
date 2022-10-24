require 'spec_helper'
require './lib/event_type'
require './lib/event'

describe Event do
  it 'has event type' do
    event = Event.new('sudoku')
    expect(event.event_type).to eq 'sudoku'
  end
  it 'has event type' do
    event = Event.new(1)
    event.load_from_json(
      {
        "id"=> '2371',
        "date"=> "2022-11-08",
        "place"=> "(GMT-05:00) Bogota",
        "capacity"=> '20',
        "city"=> "Online",
        "country_id"=> '245',
        "trainer_id"=> '57',
        "visibility_type"=> "pu",
        "list_price"=> "999.0",
        "eb_price"=> "940.0",
        "eb_end_date"=> "2022-10-29",
        "finish_date"=> "2022-12-01",
        "start_time"=> "2000-01-01T15:00:00.000Z",
        "end_time"=> "2000-01-01T17:00:00.000Z"
      }
    )

    expect(event.start_time.hour).to eq 15
    expect(event.end_time.hour).to eq 17
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
