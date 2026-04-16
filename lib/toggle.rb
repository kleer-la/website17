class Toggle
  @flags = {
    'test' => true
  }

  def self.turn(flag, value)
    @flags[flag] = value
  end

  def self.on?(flag)
    env_key = "FEATURE_#{flag.to_s.upcase}"
    return ENV[env_key] == 'true' if ENV.key?(env_key)

    !@flags[flag].nil? && @flags[flag]
  end
end
