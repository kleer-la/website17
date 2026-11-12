# The site's own styles, served as one stylesheet (website17#464). The files
# in public/app/css/site are plain CSS and are the source; joining them here
# keeps one request for the browser without a build step.
class SiteStylesheet
  # Cascade order: the palette first, then the files in the order the Sass
  # imports had. A new file goes where its rules should win.
  FILES = %w[tokens home training blog news clients about_us UIKit services business-agility
             recommended resources slider contact bookings recommended_way concepts index].freeze

  # @charset and @import only count before every rule, so their lines go first.
  HOISTED = /\A@(charset|import)\b/

  def initialize(dir)
    @paths = FILES.map { File.join(dir, "#{_1}.css") }
  end

  def version
    @paths.map { File.mtime(_1).to_i }.max
  end

  def to_css
    sources = @paths.to_h { [_1, File.read(_1)] }
    imports = sources.values.flat_map { |css| css.lines.grep(/\A@import\b/).map(&:strip) }
    bodies = sources.map { |path, css| "/* site/#{File.basename(path)} */\n#{css.lines.grep_v(HOISTED).join.strip}\n" }

    ['@charset "UTF-8";', *imports, '', *bodies].join("\n")
  end
end
