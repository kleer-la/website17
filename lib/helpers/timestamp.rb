module TimestampHelpers
  def css_url(filename)
    path = File.join(settings.public_folder, 'app/css', filename)
    mtime = File.mtime(path).to_i
    "/app/css/#{filename}?v=#{mtime}"
  end
end