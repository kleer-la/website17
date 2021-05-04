# encoding: utf-8
require File.join(File.dirname(__FILE__),'../lib/keventer_connector')
require 'spec_helper'

describe KeventerConnector do
  
  before(:each) do
    @kconn = KeventerConnector.new
  end
  
  it "should be able to return the default events xml path" do
    @kconn.events_xml_url.should == "http://eventos.kleer.la/api/events.xml"
  end
  
  it "should be able to return the default kleerers xml path" do
    @kconn.kleerers_xml_url.should == "http://eventos.kleer.la/api/kleerers.xml"
  end

  it "should be able to return the event type xml path" do
    @kconn.event_type_url(1).should == "http://eventos.kleer.la/api/event_types/1.xml"
  end

end