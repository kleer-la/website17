require_relative "../../lib/keventer_reader.rb"

def stub_connector( comercial_events = "just_one_event.xml")
  connector = double("KeventerConnector")

  allow(connector).to receive(:events_xml_url).and_return( File.join(File.dirname(__FILE__),"../../spec/#{comercial_events}"))
  allow(connector).to receive(:community_events_xml_url).and_return( File.join(File.dirname(__FILE__),"../../spec/community_events.xml") )
  allow(connector).to receive(:kleerers_xml_url).and_return( File.join(File.dirname(__FILE__),"../../spec/kleerers.xml") )
  allow(connector).to receive(:categories_xml_url).and_return( File.join(File.dirname(__FILE__),"../../spec/categories.xml") )

  KeventerReader.build_with( connector )
end

def stub_connector_community(community_events)
  connector = double("KeventerConnector")
  allow(connector).to receive(:events_xml_url).and_return( File.join(File.dirname(__FILE__),"../../spec/just_one_event.xml") )
  allow(connector).to receive(:community_events_xml_url).and_return( File.join(File.dirname(__FILE__),"../../spec/#{community_events}") )
  allow(connector).to receive(:kleerers_xml_url).and_return( File.join(File.dirname(__FILE__),"../../spec/kleerers.xml") )
  allow(connector).to receive(:categories_xml_url).and_return( File.join(File.dirname(__FILE__),"../../spec/categories.xml") )
  KeventerReader.build_with( connector )
end
