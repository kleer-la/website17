require './lib/keventer_reader'
require 'date'
require 'spec_helper'

describe 'to_boolean' do
  it 'Should convert string to true' do
    to_boolean('true').should be true
    to_boolean('True').should be true
    to_boolean('t').should be true
    to_boolean('yes').should be true
    to_boolean('y').should be true
    to_boolean('1').should be true
  end
  it 'Should convert string to false' do
    to_boolean('false').should be false
    to_boolean('f').should be false
    to_boolean('no').should be false
    to_boolean('n').should be false
    to_boolean('').should be false
    to_boolean('0').should be false
    to_boolean(nil).should be false
  end
  it 'should raise ArgumentError for arguments that are not boolean' do
    expect { to_boolean('pepe') }.to raise_error(ArgumentError)
  end
end

