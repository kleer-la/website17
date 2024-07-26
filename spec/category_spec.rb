require './lib/category'
require 'spec_helper'

describe Category do
  before(:each) do
    @category = Category.new
  end

  it 'should have a name' do
    @category.name = 'pepepe'
    expect(@category.name).to eq 'pepepe'
  end

  it 'should have a codename' do
    @category.codename = 'pepepe'
    expect(@category.codename).to eq 'pepepe'
  end

  it 'should have a tagline' do
    @category.tagline = 'pepepe'
    expect(@category.tagline).to eq 'pepepe'
  end

  it 'should have a description' do
    @category.description = 'pepepe'
    expect(@category.description).to eq 'pepepe'
  end

  it 'should have a order' do
    @category.order = 12
    expect(@category.order).to eq 12
  end
end
