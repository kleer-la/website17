class Toggle
  @flags = {
    'test' => true
  }

  def self.turn(flag, value)
    @flags[flag] = value
  end

  def self.on?(flag)
    !@flags[flag].nil? && @flags[flag]
  end
end
