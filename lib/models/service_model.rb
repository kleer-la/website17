
class Service
  attr_accessor :public_editions, :name, :subtitle, :description, :side_image, :takeaways,
                :recipients, :program, :brochure,
                :cta
  def initialize()
    @public_editions = []
    @side_image = ''
  end
end
