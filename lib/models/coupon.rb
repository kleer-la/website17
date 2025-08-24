require './lib/image_url_helper'

class Coupon
  attr_accessor :code, :percent_off, :end_date
  attr_writer :icon

  def initialize(code, percent_off, icon)
    @code = code
    @percent_off = percent_off
    @icon = icon
  end

  def icon
    ImageUrlHelper.replace_s3_with_cdn(@icon)
  end
end
