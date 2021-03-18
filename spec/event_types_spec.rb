require 'spec_helper'
require './lib/event_type'

describe EventType do
  context "Null Infra" do
    it 'has name' do
      event_type= EventType.createNull('./spec/event_type_1.xml')

      expect(event_type.id).to eq 4
      expect(event_type.name).to eq 'Introducción a Scrum (Módulo 1 - CSD Track)'
    end
  end
end