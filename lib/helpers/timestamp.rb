require './lib/site_stylesheet'

module TimestampHelpers
  def css_url(filename)
    path = File.join(settings.public_folder, 'app/css', filename)
    mtime = File.mtime(path).to_i
    "/app/css/#{filename}?v=#{mtime}"
  end

  def site_stylesheet_url
    "/app/css/site.css?v=#{site_stylesheet.version}"
  end

  def site_stylesheet
    SiteStylesheet.new(File.join(settings.public_folder, 'app/css/site'))
  end
end
