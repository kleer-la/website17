require './lib/keventer_event'
require './lib/professional'
require './lib/keventer_event_type'

EVENT_XML = %(<?xml version="1.0" encoding="UTF-8"?>
  <event>
    <address>address qq</address>
    <average-rating type="decimal" nil="true"/>
    <business-eb-price type="decimal">85.0</business-eb-price>
    <business-price type="decimal">88.0</business-price>
    <cancelled type="boolean">false</cancelled>
    <capacity type="integer">11</capacity>
    <city>city yy</city>
    <country-id type="integer">2</country-id>
    <couples-eb-price type="decimal">90.0</couples-eb-price>
    <created-at type="datetime">2015-05-11T22:48:10Z</created-at>
    <currency-iso-code>AED</currency-iso-code>
    <custom-prices-email-text></custom-prices-email-text>
    <date type="date">2015-05-18</date>
    <draft type="boolean">false</draft>
    <duration type="integer">1</duration>
    <eb-end-date type="date">2015-05-08</eb-end-date>
    <eb-price type="decimal">95.0</eb-price>
    <embedded-player nil="true"/>
    <end-time type="datetime">2000-01-01T18:00:00Z</end-time>
    <enterprise-11plus-price type="decimal">80.0</enterprise-11plus-price>
    <enterprise-6plus-price type="decimal">83.0</enterprise-6plus-price>
    <event-type-id type="integer">5</event-type-id>
    <finish-date type="date">2015-05-21</finish-date>
    <id type="integer">35</id>
    <is-sold-out type="boolean">false</is-sold-out>
    <list-price type="decimal">100.0</list-price>
    <mode>cl</mode>
    <monitor-email></monitor-email>
    <net-promoter-score type="integer" nil="true"/>
    <notify-webinar-start type="boolean">false</notify-webinar-start>
    <place>the place pp</place>
    <registration-link></registration-link>
    <sepyme-enabled type="boolean">false</sepyme-enabled>
    <should-ask-for-referer-code type="boolean">false</should-ask-for-referer-code>
    <should-welcome-email type="boolean">true</should-welcome-email>
    <show-pricing type="boolean">false</show-pricing>
    <specific-conditions>Very specific</specific-conditions><specific-subtitle></specific-subtitle>
    <start-time type="datetime">2000-01-01T09:00:00Z</start-time>
    <time-zone-name></time-zone-name>
    <trainer-id type="integer">2</trainer-id>
    <twitter-embedded-search nil="true"/>
    <updated-at type="datetime">2015-05-11T23:06:08Z</updated-at>
    <visibility-type>pu</visibility-type>
    <webinar-started type="boolean">false</webinar-started>
    <human-date>18-1 May</human-date>
    <is-webinar type="boolean">false</is-webinar><enable-online-payment type="boolean">false</enable-online-payment>
    <online-course-codename></online-course-codename><online-cohort-codename></online-cohort-codename>
    <banner-text>un texto a resaltar</banner-text>
    <banner-type>success</banner-type>
    <country>
      <created-at type="datetime">2012-04-25T20:31:03Z</created-at>
      <id type="integer">2</id>
      <iso-code>DZ</iso-code>
      <name>Algeria</name>
      <updated-at type="datetime">2012-04-25T20:31:03Z</updated-at>
    </country>
    <event-type>
      <average-rating type="decimal" nil="true"/>
      <created-at type="datetime">2014-09-27T17:34:01Z</created-at>
      <csd-eligible type="boolean">false</csd-eligible>
      <description>de tres dias</description>
      <duration type="integer">24</duration>
      <elevator-pitch>de tres dias</elevator-pitch>
      <faq></faq>
      <goal></goal>
      <id type="integer">5</id>
      <include-in-catalog type="boolean">false</include-in-catalog>
      <learnings></learnings>
      <materials></materials>
      <name>Curso de 3 días</name>
      <net-promoter-score type="integer" nil="true"/>
      <program>de tres dias</program>
      <promoter-count type="integer" nil="true"/>
      <recipients>de tres dias</recipients>
      <surveyed-count type="integer" nil="true"/>
      <tag-name></tag-name>
      <takeaways></takeaways>
      <updated-at type="datetime">2014-09-27T17:34:01Z</updated-at>
    </event-type>
    <trainer>
      <average-rating type="decimal">5.0</average-rating>
      <bio></bio>
      <bio-en nil="true"/>
      <country-id type="integer">1</country-id>
      <created-at type="datetime">2012-04-25T20:31:04Z</created-at>
      <gravatar-email></gravatar-email>
      <id type="integer">2</id>
      <is-kleerer type="boolean">true</is-kleerer>
      <linkedin-url></linkedin-url>
      <name>Jeff Baurer</name>
      <net-promoter-score type="integer">100</net-promoter-score>
      <promoter-count type="integer">1</promoter-count>
      <signature-credentials>Agile Coach &amp; Trainer</signature-credentials>
      <signature-image>PT.png</signature-image>
      <surveyed-count type="integer">1</surveyed-count>
      <tag-name>TR-JB (Jeff Baurer - Prueba Keventer)</tag-name>
      <twitter-username></twitter-username>
      <updated-at type="datetime">2014-06-29T21:53:13Z</updated-at>
      <gravatar-picture-url>https://www.gravatar.com/avatar/d41d8cd98f00b204e9800998ecf8427e</gravatar-picture-url>
    </trainer>
    <categories type="array">
      <category>
        <codename>productos</codename>
        <created-at type="datetime">2013-04-19T14:28:15Z</created-at>
        <description>Nos enfocamos en las prácticas de diseño e ingeniería necesarias para garantizar
        la calidad durante la concepción y construcción, el mantenimiento y el uso de tus productos.
        La calidad importa y hace la diferencia pero no ocurre magicamente. Deben aplicarse, disciplinada
        y consistentemente las mejores prácticas de la industria para lograrlo.
        **Desde Kleer podemos ayudarte a integrar las mejores prácticas a la cultura de su empresa.**
        Para eso demostramos y ensayamos técnicas y estrategias, y te acompañamos junto a tu equipo en diferentes
        momentos del ciclo de vida de tus proyectos.</description>
        <description-en></description-en>
        <id type="integer">3</id>
        <name>Productos tecnológicos de calidad</name>
        <name-en>Quality technological products</name-en>
        <order type="integer">2</order>
        <tagline>Integración continua, Test Driven Development, Pair Programming, Refactoring.</tagline>
        <tagline-en></tagline-en>
        <updated-at type="datetime">2014-10-02T10:24:26Z</updated-at>
        <visible type="boolean">true</visible>
      </category>
    </categories>
  </event>
).freeze

describe KeventerEvent do
  before(:each) do
    @kevent = KeventerEvent.new
  end

  it 'should have an id' do
    @kevent.id = 10
    @kevent.id.should == 10
  end

  it 'should have a keventer connector' do
    kc = KeventerConnector.new
    @kevent.keventer_connector = kc
    @kevent.keventer_connector.should == kc
  end

  it 'should have a capacity' do
    @kevent.capacity = 10
    @kevent.capacity.should == 10
  end

  it 'should have a date' do
    a_date = Date.new
    @kevent.date = a_date
    @kevent.date.should == a_date
  end

  it 'should have a start time' do
    a_time = Time.new
    @kevent.start_time = a_time
    @kevent.start_time.should == a_time
  end

  it 'should have an end time' do
    a_time = Time.new
    @kevent.end_time = a_time
    @kevent.end_time.should == a_time
  end

  it 'should have a human date' do
    @kevent.human_date = '18-19 Abr'
    @kevent.human_date.should == '18-19 Abr'
  end

  it 'should have a registration_link' do
    @kevent.registration_link = 'https://www.kleer.la'
    @kevent.registration_link.should == 'https://www.kleer.la'
  end

  it 'should have an address' do
    @kevent.address = 'https://www.kleer.la'
    @kevent.address.should == 'https://www.kleer.la'
  end

  it 'should have a sold-out flag' do
    @kevent.is_sold_out = false
    @kevent.is_sold_out.should == false
  end

  it 'should have a sepyme_enabled flag' do
    @kevent.sepyme_enabled = false
    @kevent.sepyme_enabled.should == false
  end

  it 'should have a show_pricing flag' do
    @kevent.show_pricing = false
    @kevent.show_pricing.should == false
  end

  it 'should have a place' do
    @kevent.place = 'Kleer, Tucuman 373 1er Piso'
    @kevent.place.should == 'Kleer, Tucuman 373 1er Piso'
  end

  it 'should have a city' do
    @kevent.city = 'Buenos Aires'
    @kevent.city.should == 'Buenos Aires'
  end

  it 'should have a country' do
    @kevent.country = 'Argentina'
    @kevent.country.should == 'Argentina'
  end

  it 'should have a country_code' do
    @kevent.country_code = 'ar'
    @kevent.country_code.should == 'ar'
  end

  it 'should have a mode' do
    @kevent.mode = 'ar'
    @kevent.mode.should == 'ar'
  end

  it 'should have an event type' do
    an_event_type = KeventerEventType.new
    @kevent.event_type = an_event_type
    @kevent.event_type.should == an_event_type
  end

  it 'should have a list_price' do
    @kevent.list_price = 12.0
    expect(@kevent.list_price).to eq 12.0
  end

  it 'should have a eb_price' do
    @kevent.eb_price = 12.0
    expect(@kevent.eb_price).to eq 12.0
  end

  it 'should have a couples_eb_price' do
    @kevent.couples_eb_price = 12.0
    expect(@kevent.couples_eb_price).to eq 12.0
  end

  it 'should have a business_eb_price' do
    @kevent.business_eb_price = 12.0
    expect(@kevent.business_eb_price).to eq 12.0
  end

  it 'should have a business_price' do
    @kevent.business_price = 12.0
    expect(@kevent.business_price).to eq 12.0
  end

  it 'should have a enterprise_6plus_price' do
    @kevent.enterprise_6plus_price = 12.0
    expect(@kevent.enterprise_6plus_price).to eq 12.0
  end

  it 'should have a enterprise_11plus_price' do
    @kevent.enterprise_11plus_price = 12.0
    expect(@kevent.enterprise_11plus_price).to eq 12.0
  end

  it 'should have a discount' do
    @kevent.list_price = 12.0
    @kevent.eb_price = 10.5
    expect(@kevent.discount).to eq 1.5
  end

  it 'should have a discount' do
    @kevent.list_price = 12.0
    @kevent.eb_price = 0.0
    expect(@kevent.discount).to eq 0.0
  end

  it 'should have a discount' do
    @kevent.list_price = 12.0
    @kevent.eb_price = nil
    expect(@kevent.discount).to eq 0.0
  end

  it 'should have a eb_end_date' do
    a_date = Date.new
    @kevent.eb_end_date = a_date
    expect(@kevent.eb_end_date).to eq a_date
  end

  it 'should have a currency_iso_code' do
    @kevent.currency_iso_code = 'ARS'
    expect(@kevent.currency_iso_code).to eq 'ARS'
  end

  it 'should have specific_conditions' do
    @kevent.specific_conditions = 'Condiciones Especiales de Evento'
    @kevent.specific_conditions.should == 'Condiciones Especiales de Evento'
  end

  context 'If the trainer is Raul Gorgonzola' do
    before(:each) do
      @trainer = Professional.new
      @trainer.name = 'Raul Gorgonzola'
      @trainer.bio = 'hg jgjhagsdjhagsdkjahgsfkjahgsj ja sfkjahs fkjahsfg'

      @kevent.add_trainer @trainer
    end

    it 'should have a trainer' do
      @kevent.trainers[0].should == @trainer
    end

    it 'should have a deprecated trainer name backward compatible' do
      @kevent.trainers[0].name.should == @trainer.name
    end

    it 'should have a trainer bio backward compatible' do
      @kevent.trainers[0].bio.should == @trainer.bio
    end
  end

  context 'Trainers and cotrainers' do
    before(:each) do
      @trainer = Professional.new
      @trainer.name = 'Rogna Castro'
      @trainer.bio  = 'Da clases de guitarra por fax'

      @cotrainer = Professional.new
      @cotrainer.name = 'Natty Dread'
      @cotrainer.bio  = 'Artifice del Mate Loco'
    end

    it 'should have a co-trainer' do
      @kevent.add_trainer @cotrainer
      expect(@kevent.trainers[0]).to eq @cotrainer
      expect(@kevent.trainers).to eq [@cotrainer]
    end
    it 'should have a trainer and NO co-trainer' do
      @kevent.add_trainer @trainer
      @kevent.add_trainer nil
      expect(@kevent.trainers[0]).to eq @trainer
      @kevent.trainers[1].should.nil?
      expect(@kevent.trainers).to eq [@trainer]
    end

    it 'NG should have a trainer and co-trainer' do
      @kevent.add_trainer @trainer
      @kevent.add_trainer @cotrainer
      expect(@kevent.trainers).to eq [@trainer, @cotrainer]
    end
  end

  # it 'should form the uri path automatically' do #TODO deprecated
  #   @kevent.id = 44
  #   an_event_type = KeventerEventType.new
  #   an_event_type.name = 'Workshop de Retrospectivas'
  #   @kevent.event_type = an_event_type
  #   @kevent.city = 'Buenos Aires'
  #   @kevent.uri_path.should == '44-workshop-de-retrospectivas-buenos-aires'
  # end

  it 'should form the friendly title automatically' do
    @kevent.id = 44
    an_event_type = KeventerEventType.new
    an_event_type.name = 'Workshop de Retrospectivas'
    @kevent.event_type = an_event_type
    @kevent.city = 'Buenos Aires'
    @kevent.friendly_title.should == 'Workshop de Retrospectivas - Buenos Aires'
  end

  context 'Loding from xml' do
    before(:each) do
      @xml = EVENT_XML
      parser = LibXML::XML::Parser.string(@xml)
      doc = parser.parse
      doc.find('/event')
      @kevent.load doc
    end

    it 'should load a description' do
      expect(@kevent.id).to eq(35)
      expect(@kevent.capacity).to eq(11)
      expect(@kevent.place).to eq('the place pp')
      expect(@kevent.city).to eq('city yy')
      expect(@kevent.address).to eq('address qq')
      expect(@kevent.registration_link).to eq('')
      expect(@kevent.country).to eq('Algeria')
      expect(@kevent.country_code).to eq('DZ')
    end

    it 'should load the dates and time' do
      expect(@kevent.event_type).to eq(nil)
      expect(@kevent.date).to eq(Date.new(2015, 5, 18))
      expect(@kevent.finish_date).to eq(Date.new(2015, 5, 21))
      expect(@kevent.start_time).to eq(DateTime.new(2000, 1, 1, 9))
      expect(@kevent.end_time).to eq(DateTime.new(2000, 1, 1, 18))
    end

    it 'should load details' do
      expect(@kevent.specific_conditions).to eq('Very specific')
      expect(@kevent.sepyme_enabled).to eq(false)
      expect(@kevent.mode).to eq('cl')
    end

    it 'should load status' do
      expect(@kevent.is_sold_out).to eq(false)
    end

    it 'should load prices' do
      expect(@kevent.is_sold_out).to eq(false)
      expect(@kevent.show_pricing).to eq(false)
      expect(@kevent.list_price).to eq(100)
      expect(@kevent.eb_price).to eq(95)
      expect(@kevent.eb_end_date).to eq(Date.new(2015, 5, 8))
      expect(@kevent.couples_eb_price).to eq(90)
      expect(@kevent.business_eb_price).to eq(85)
      expect(@kevent.business_price).to eq(88)
      expect(@kevent.enterprise_6plus_price).to eq(83)
      expect(@kevent.enterprise_11plus_price).to eq(80)
    end
  end

  context 'timezone convertion' do
    context 'generate an url' do
      before(:example) do
        @kevent.date = Date.parse('2015-05-18')
        @kevent.start_time = DateTime.parse('2000-01-01T09:00:00Z')
        @kevent.end_time = DateTime.parse('2000-01-01T18:00:00Z')
        @kevent.place = '(GMT-05:00) Bogota'
        an_event_type = KeventerEventType.new
        an_event_type.name = 'CSM Online'
        @kevent.event_type = an_event_type
      end
      it 'name' do
        expect(@kevent.timezone_url).to include 'msg=CSM+Online'
      end
      it 'date & time' do
        expect(@kevent.timezone_url).to include 'iso=20150518T0900'
      end
      it 'city' do
        expect(@kevent.timezone_url).to include 'p1=41'
      end
      it 'duration' do
        @kevent.end_time = DateTime.parse('2000-01-01T17:15:00Z')
        expect(@kevent.timezone_url).to include 'ah=8&am=15'
      end
      it 'whole url' do
        expect(@kevent.timezone_url).to include 'https://www.timeanddate.com/worldclock/fixedtime.html?msg=CSM+Online&iso=20150518T0900&p1=41&ah=9&am=0'
      end
    end
  end
end
