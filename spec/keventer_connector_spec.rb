require './lib/keventer_connector'
require 'spec_helper'

describe KeventerConnector do
  before(:each) do
    @kconn = KeventerConnector.new
  end

  it 'should be able to return the default events xml path' do
    expect(@kconn.events_xml_url).to end_with '/api/events.xml'
  end

  it 'should be able to return the default kleerers xml path' do
    expect(@kconn.kleerers_xml_url).to end_with '/api/kleerers.xml'
  end

  it 'should be able to return the event type xml path' do
    expect(@kconn.event_type_url(1)).to end_with '/api/event_types/1.xml'
  end

  context 'Connector new scope' do
    it 'get Catalog read a Json array' do
      json_response = '''
      [{"event_id":2337,"date":"2022-08-01","finish_date":"2022-08-01","city":"2022-08-01","specific_subtitle":"",
        "country_name":"-- OnLine --","country_iso":"OL","event_type_id":7,"name":"Certified Scrum Master (CSM)",
        "cover":"https://kleer-images.s3.sa-east-1.amazonaws.com/training/CSM/cover.webp",
        "categories":[{"id":3,"name":"Desarrollo Profesional"}],"lang":"es","slug":"7-certified-scrum-master-csm",
        "csd_eligible":true,"is_kleer_certification":false},{"event_id":2334,"date":"2022-08-09",
        "finish_date":"2022-08-09","city":"2022-08-09","specific_subtitle":"","country_name":"-- OnLine --",
        "country_iso":"OL","event_type_id":339,"name":"Comunicación Colaborativa",
        "cover":"https://kleer-images.s3.sa-east-1.amazonaws.com/training/COMCOL/cover.webp",
        "categories":[{"id":3,"name":"Desarrollo Profesional"}],"lang":"es","slug":"339-comunicacion-colaborativa",
        "csd_eligible":false,"is_kleer_certification":false}
      ]
      '''
      kconn = KeventerConnector.new(json_response)
      expect(kconn.get_catalog.count).to be > 0
    end
  end
end
