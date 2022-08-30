class Event
  attr_accessor :event_type, :country, :certified, :date,
                :finish_date, :price, :eb_price, :eb_date,
                :is_sold_out, :id, :start_time, :end_time,
                :timezone_url, :place

  def initialize(event_type)
    @event_type = event_type
    @country = 'OL'
  end
end

class EventFacade
  attr_reader :name, :subtitle, :cover,
              :certified, :slug, :categories,
              :date,:finish_date, :country

  def initialize()
    @name = @subtitle= @cover =
    @certified= @slug= @categories =
    @date= @country = nil
  end

  def from_event_type(et)
    @name = et.name
    @subtitle = et.subtitle
    @cover = et.cover
    @certified= (2 if et.is_sa_cert).to_i +
                (1 if et.is_kleer_cert).to_i
    @slug = et.slug
    @categories = et.categories
    self
  end
  def from_event(e)
    @date = e.date
    @country = e.country
    from_event_type(e.event_type)
  end

end
