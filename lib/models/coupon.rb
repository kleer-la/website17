class Coupon
  attr_accessor :code, :percent_off, :icon, :end_date

  def initialize(code, percent_off, icon)
    @code = code
    @percent_off = percent_off
    @icon = icon
  end
end