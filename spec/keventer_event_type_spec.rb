require 'spec_helper'
require 'xml'
require './lib/keventer_event_type'

INITIAL_XML = %(<?xml version="1.0" encoding="UTF-8"?>
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
  <categories type="array">
  <category>
    <codename>organizaciones</codename>
    <created-at type="datetime">2013-04-19T17:36:06Z</created-at>
    <description>Proponemos un nuevo enfoque de gestión de organizaciones, áreas, departamentos y equipos de
    trabajo que se enfoca en las personas y sus interacciones por sobre los procesos y las herramientas utilizadas.

    Las organizaciones y los equipos de trabajo están compuestos por personas y las personas tienen comportamientos,
    deseos, emociones; no son "recursos". La creación de productos y/o servicios innovadores es, principalmente, una
    actividad social que tiene lugar dentro de un equipo de personas, en contextos más participativos, colaborativos
    y humanos. Por consiguiente, la manera más efectiva de mejorar los resultados es mejorando las relaciones que
    existen entre los miembros y no solamente atendiendo los procesos y las tareas que ellos realizan.

    **Te podemos asistir para lograr que tu organización, área, departamento o equipo de trabajo, logre un nivel de
    rendimiento superior al actual.**

    Contactate con nosotros en coaching@kleer.la</description>
    <description-en>We propose a new approach to management of organizations, departments and teams that focuses on
    people and their interactions over processes and tools used.
    </description-en>
    <id type="integer">2</id>
    <name>Organizaciones asombrosas</name>
    <name-en>Amazing organizations</name-en>
    <order type="integer">1</order>
    <tagline>A partir del aprendizaje, la confianza, el compromiso, la visibilidad y la flexibilidad tu
    organización, departamento o equipo de trabajo logrará resultados nunca antes vistos.</tagline>
    <tagline-en>Thru learning, trust, commitment, visibility and flexibility your organization, department
    or team achieve results never seen before.</tagline-en>
    <updated-at type="datetime">2014-10-03T11:24:04Z</updated-at>
    <visible type="boolean">true</visible>
    </category>
  </categories>
).freeze

describe KeventerEventType do
  before(:each) do
    @keventtype = KeventerEventType.new
  end

  it 'should have a name' do
    @keventtype.name = 'Workshop de Retrospectivas'
    expect(@keventtype.name).to eq 'Workshop de Retrospectivas'
  end

  it 'should have a goal' do
    @keventtype.goal = 'Buenos Aires'
    expect(@keventtype.goal).to eq 'Buenos Aires'
  end

  it 'should have a description' do
    @keventtype.description = 'Argentina'
    expect(@keventtype.description).to eq 'Argentina'
  end

  it 'should have a elevator_pitch' do
    @keventtype.elevator_pitch = 'Argentina'
    expect(@keventtype.elevator_pitch).to eq 'Argentina'
  end

  it 'should have rating instance variable' do
    expect(@keventtype.average_rating).to eq 0.0
    expect(@keventtype.net_promoter_score).to eq 0
    expect(@keventtype.surveyed_count).to eq 0.0
  end

  it "new event_type doesn't have rate" do
    @keventtype.has_rate.should be false
  end

  it 'should have rate' do
    @keventtype.average_rating = 3
    @keventtype.surveyed_count = 100
    @keventtype.has_rate.should be true
  end

  it "empty event_type doesn't have rate" do
    @keventtype.average_rating = nil
    @keventtype.surveyed_count = 100
    @keventtype.has_rate.should be false
  end

  it 'should have a learnings' do
    @keventtype.learnings = 'Argentina'
    expect(@keventtype.learnings).to eq 'Argentina'
  end

  it 'should have a takeaways' do
    @keventtype.takeaways = 'Argentina'
    expect(@keventtype.takeaways).to eq 'Argentina'
  end

  it 'should have a program' do
    @keventtype.program = 'ar'
    expect(@keventtype.program).to eq 'ar'
  end

  it 'should have a duration' do
    @keventtype.duration = 16
    expect(@keventtype.duration).to eq 16
  end

  it 'should have some recipients' do
    @keventtype.recipients = 'sdkjfhskjfhskdjf'
    expect(@keventtype.recipients).to eq 'sdkjfhskjfhskdjf'
  end

  it 'should have some FAQs' do
    @keventtype.faqs = 'sdkjfhskjfhskdjf'
    expect(@keventtype.faqs).to eq 'sdkjfhskjfhskdjf'
  end

  it 'should have an empty subtitle on creatio' do
    expect(@keventtype.subtitle).to eq('')
  end

  context 'Loding from xml' do
    def build_and_parse(xml_element = '')
      closing = '</event-type>'
      parser = XML::Parser.string(INITIAL_XML + xml_element + closing)
      doc = parser.parse
      doc.find('/event_type')
      doc
    end

    it 'should load basic info: id, description & duration' do
      @keventtype.load build_and_parse('')

      expect(@keventtype.id).to eq(5)
      expect(@keventtype.name).to eq('Curso de 3 días')
      expect(@keventtype.duration).to eq(24)
    end

    it 'should load an emtpy subtitle' do
      @keventtype.load build_and_parse('<subtitle type="string" nil="true"/>')

      expect(@keventtype.subtitle).to eq('')
    end

    it 'should load a subtitle' do
      @keventtype.load build_and_parse('<subtitle>Good to see you!</subtitle>')

      expect(@keventtype.subtitle).to eq('Good to see you!')
    end

    it 'should have categories' do
      @keventtype.load build_and_parse

      expect(@keventtype.categories).to eq [[2, 'organizaciones']]
    end
  end
end
