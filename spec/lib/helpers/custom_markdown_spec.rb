require 'spec_helper'
require './lib/helpers/custom_markdown'

describe CustomMarkdown do
  it 'nil text' do
    markdown_renderer = CustomMarkdown.new

    expect(markdown_renderer.render(nil)).to eq ''
  end
end
