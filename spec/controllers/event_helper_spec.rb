require './controllers/event_helper'

describe 'fake_event_from_catalog' do
  before(:each) do
    @connector = double('KeventerConnector')
    @connector.stub(:categories_xml_url).and_return(File.join(File.dirname(__FILE__),
                                                              '../categories.xml'))

    KeventerReader.build_with(@connector)
    @kevr = KeventerReader.instance
  end
  
  it 'has many' do
    cat = @kevr.categories
    events= fake_event_from_catalog(@kevr.categories)
    expect(events.count).to eq 3
  end
  it 'has many' do
    cat = @kevr.categories
    events= fake_event_from_catalog(@kevr.categories)
    expect(events[0].event_type.name).to eq 'Tipo de Evento de Prueba'
  end
end