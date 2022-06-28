
def fake_event_from_catalog(categories)
  categories.reduce([]) {|acat, cat|
    acat + cat.event_types.reduce([]) {|ac, ev| ac << Event.new(ev) }
  }
end
