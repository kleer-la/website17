class Country
  attr_reader :iso_code, :name

  def initialize(iso_code, name)
    @iso_code = iso_code
    @name = name
  end

  def ==(other)
    @iso_code == other.iso_code
  end
end
