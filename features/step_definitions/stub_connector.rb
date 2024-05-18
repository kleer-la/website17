def stub_connector(comercial_events = '')
  connector = double('KeventerConnector')

  catalog = NullJsonAPI.new(nil, File.read('./spec/catalog.json'))

  allow(connector).to receive(:get_catalog).and_return(catalog)
end
