def stub_connector(comercial_events = '')
  catalog = NullJsonAPI.new(nil, File.read('./spec/catalog.json'))
end
