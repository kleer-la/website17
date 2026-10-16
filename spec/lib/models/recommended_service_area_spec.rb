require_relative '../../spec_helper'
require './lib/models/recommended'

RSpec.describe RecommendedServiceArea do
  let(:area_data) do
    { 'type' => 'service_area', 'title' => 'Cambio Organizacional', 'subtitle' => 'Transformá tu organización',
      'slug' => 'cambio-organizacional', 'lang' => 'es', 'is_training_program' => false }
  end

  it 'is built for the service_area type, which would be dropped in silence' do
    expect(Recommended.create(area_data)).to be_a(RecommendedServiceArea)
  end

  it 'links to the services section, in each language' do
    expect(Recommended.create(area_data).url).to eq('/es/servicios/cambio-organizacional')
    expect(Recommended.create(area_data.merge('lang' => 'en')).url).to eq('/en/services/cambio-organizacional')
  end

  it 'links a training area to the training section' do
    training = area_data.merge('is_training_program' => true)

    expect(Recommended.create(training).url).to eq('/es/formacion/cambio-organizacional')
    expect(Recommended.create(training.merge('lang' => 'en')).url).to eq('/en/training/cambio-organizacional')
  end
end
