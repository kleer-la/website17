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
end
