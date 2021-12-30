require './controllers/helper'

class TestHelper
  include Helpers
end

describe 'helpes' do
  let(:helpers) { TestHelper.new }
  it 'Sanitize URL' do
    expect(helpers.url_sanitize('áéíóúÁËÍÖÜ')).to eq 'aeiouAEIOU'
  end
end
