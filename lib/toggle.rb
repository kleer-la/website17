require 'flipper'

if ENV['RACK_ENV'] == 'test'
  Flipper.configure do |config|
    config.default do
      Flipper.new(Flipper::Adapters::Memory.new)
    end
  end
else
  require 'flipper/adapters/pstore'

  pstore_path = File.join(File.dirname(__FILE__), '..', 'tmp', 'flipper.pstore')
  FileUtils.mkdir_p(File.dirname(pstore_path))

  Flipper.configure do |config|
    config.default do
      Flipper.new(Flipper::Adapters::PStore.new(pstore_path))
    end
  end
end

class Toggle
  def self.turn(flag, value)
    if value
      Flipper.enable(flag)
    else
      Flipper.disable(flag)
    end
  end

  def self.on?(flag)
    Flipper.enabled?(flag)
  end
end
