require_relative '../../lib/keventer_reader'

def stub_connector(comercial_events = 'just_one_event.xml')
  connector = double('KeventerConnector')

  catalog = NullJsonAPI.new(nil, File.read('./spec/catalog.json'))

  allow(connector).to receive(:get_catalog).and_return(catalog)
  allow(connector).to receive(:events_xml_url).and_return("./spec/#{comercial_events}")
  allow(connector).to receive(:kleerers_xml_url).and_return('./spec/kleerers.xml')
  allow(connector).to receive(:categories_xml_url).and_return('./spec/categories.xml')

  KeventerReader.build_with(connector)
end
