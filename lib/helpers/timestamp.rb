module TimestampHelpers
  # The site's own stylesheets, in cascade order: the palette first, then the
  # files in the order the Sass imports had before the CSS became the source
  # (website17#464). A new file goes where its rules should win.
  SITE_STYLESHEETS = %w[tokens home training blog news clients about_us UIKit services business-agility
                        recommended resources slider contact bookings recommended_way concepts index].freeze

  def css_url(filename)
    path = File.join(settings.public_folder, 'app/css', filename)
    mtime = File.mtime(path).to_i
    "/app/css/#{filename}?v=#{mtime}"
  end

  def site_stylesheets
    SITE_STYLESHEETS.map { |name| css_url("site/#{name}.css") }
  end
end
