class AcademyCourses
  def initialize
    @courses = []
  end

  def all
    @courses
  end

  def load
    file = File.read('./lib/academy_storage.json')
    @courses = JSON.parse(file)['academy_courses']
    self
  end

  def select(lang, quantity)
    @courses
    .reject {|e| e[lang].nil?}
    .map {|e| e[lang]}
    .first(quantity)
  end
end
