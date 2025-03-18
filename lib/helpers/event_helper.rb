# app/helpers/event_helper.rb
module EventHelper
  def calculate_event_pricing(event, today = Date.today)
    list_price = event.list_price.to_f
    eb_price = event.eb_price&.to_f
    eb_date = event.eb_date ? Date.parse(event.eb_date) : nil
    coupon = event.event_type.coupons[0]

    # Determine if EB price is valid
    show_eb_price = eb_price && eb_date && eb_date >= today
    price_off = show_eb_price ? eb_price : list_price
    using_coupon = false

    # Apply coupon if available and better than EB price
    if coupon
      coupon_price = list_price - (list_price * coupon.percent_off.to_i / 100)
      if coupon_price < price_off
        price_off = coupon_price
        using_coupon = true
      end
    end

    {
      list_price: list_price,
      final_price: price_off,
      show_eb_price: show_eb_price,
      using_coupon: using_coupon,
      eb_date: eb_date,
      coupon: coupon
    }
  end

  def format_price(event, price)
    "#{event.currency_iso_code} #{money_format(price)}"
  end

  def format_date_range(start_date, end_date, locale)
    # Assuming this is defined elsewhere; move it here if needed
    super(start_date, end_date, locale)
  end

  def event_time_info(event)
    t("course_landing.event.time",
      starts: event.start_time.strftime("%k:%M"),
      ends: event.end_time.strftime("%k:%M"))
  end

  def specific_conditions_popup(event, markdown_renderer)
    return nil if event.specific_conditions.to_s.empty?
    {
      open: '<div class="more-info rounded">',
      close: "<span class=\"tooltip-icon\"></span><div class=\"more-info__popup\">#{markdown_renderer.render(event.specific_conditions)}</div></div>"
    }
  end
end