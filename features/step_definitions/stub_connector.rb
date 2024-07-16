def stub_connector(_comercial_events = '')
  catalog = NullJsonAPI.new(nil, File.read('./spec/catalog.json'))
end
