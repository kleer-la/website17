def stub_connector(_comercial_events = '')
  # NullJsonAPI.new(nil, File.read('./spec/catalog.json'))
  Page.api_client = NullJsonAPI.new(nil)
end
