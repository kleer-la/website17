class Event
  attr_accessor :event_type, :country_iso, :country_name, :certified, :date,
                :finish_date, :price, :eb_price, :eb_date,
                :is_sold_out, :id, :start_time, :end_time,
                :timezone_url, :place, :city

  def initialize(event_type)
    @event_type = event_type
    @country_iso = 'OL'
  end
end

class EventFacade
  attr_reader :name, :subtitle, :cover,
              :certified, :slug, :categories,
              :date,:finish_date, :country_iso, :country_name, :city

  def initialize()
    @name = @subtitle= @cover =
    @certified= @slug= @categories =
    @date= @country_iso = @country_name = @city = nil
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
    @country_iso = e.country_iso
    @country_name = e.country_name
    from_event_type(e.event_type)
  end

end
