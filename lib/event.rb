class Event
  attr_accessor :event_type, :country, :certified
  def initialize(event_type)
    @event_type = event_type
    @country = 'OL'
  end
end