require 'nokogiri'

class CustomMarkdown# < Redcarpet::Markdown
  def initialize
    @markdown_render = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(hard_wrap: true),
      autolink: true
    )
  end

  def render(text)
    html = @markdown_render.render(text)

    document = Nokogiri::HTML.fragment(html)
    images = document.css('img')
    images.each do |image|
      image['loading'] = 'lazy'
    end

    document.to_html
  end
end
