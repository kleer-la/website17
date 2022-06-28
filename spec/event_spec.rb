require './lib/event'

describe Event do
  it "has event type" do
    event = Event.new('sudoku')
    expect(event.event_type).to eq 'sudoku'
  end
end
