require './lib/timezone_converter'

describe TimezoneConverter do
  it 'exact match of Buenos Aires' do
    expect(TimezoneConverter.timezone('Buenos Aires')).to eq 51
  end
  it 'partial match of Buenos Aires' do
    expect(TimezoneConverter.timezone('Buenos Aires (Argentina)')).to eq 51
  end
  it 'not found' do
    expect(TimezoneConverter.timezone('Minas Tirith (Gondor)')).to be nil
  end
end
