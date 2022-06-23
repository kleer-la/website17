class Resources
  def initialize
    @resources = []
  end

  def all
    @resources
  end

  def load(file = File.read('./lib/resources_storage.json'))
    @resources = JSON.parse(file)['resources']
    # copy_lang('es', 'en')
    self
  end

  def copy_lang(orig, dest)
    @resources.each { |r| r[dest] = r[orig] if r[dest].nil? }
  end
end
