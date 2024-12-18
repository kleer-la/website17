TIMEZONES = [
  [155, 'Mexico City', '-06:00'],
  [41, 'Bogota', '-05:00'],
  [131, 'Lima', '-05:00'],
  [190, 'Quito', '-05:00'],
  [58, 'Caracas', '-04:00'],
  [124, 'La Paz', '-04:00'],
  [232, 'Santiago', '-04:00'],
  [45, 'Brasilia', '-03:00'],
  [51, 'Buenos Aires', '-03:00'],
  [163, 'Montevideo', '-03:00'],
  [192, 'Panama', '-05:00'],
  [133, 'Lisbon', '+00:00'],
  [136, 'London', '+00:00'],
  [37, 'Berlin', '+01:00'],
  [141, 'Madrid', '+01:00'],
  [195, 'Paris', '+01:00'],
  [204, 'Prague', '+01:00'],
  [215, 'Rome', '+01:00'],
  [225, 'San Jose', '-06:00'],
  [228, 'San Salvador', '-06:00']
].freeze

class TimezoneConverter
  def self.timezone(name)
    (
      TIMEZONES.detect { |tz| name.match(/#{tz[1]}/) }
    )&.[](0)
  end

  def self.gmt(name)
    g = (
      TIMEZONES.detect { |tz| name.match(/#{tz[1]}/) }
    )&.[](2)

    "GMT#{g}" unless g.to_s == ''
  end
end
