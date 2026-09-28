require './lib/image_url_helper'

# The picture beside the hero text of an area or service page, and the fact
# shown over it. Each reads nil when empty: no picture keeps the hero in one
# column, no highlight shows the picture alone.
module HeroPicture
  HERO_PICTURE_FIELDS = %i[hero_image hero_highlight hero_highlight_text].freeze

  attr_writer(*HERO_PICTURE_FIELDS)

  def hero_image
    presence(ImageUrlHelper.replace_s3_with_cdn(@hero_image))
  end

  def hero_highlight
    presence(@hero_highlight)
  end

  def hero_highlight_text
    presence(@hero_highlight_text)
  end

  private

  def presence(value)
    text = value.to_s.strip
    text.empty? ? nil : text
  end
end
