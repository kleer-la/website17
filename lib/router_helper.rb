class RouterHelper
  attr_accessor :routes, :current_route, :alternate_route, :lang

  def set_current_route(current_route)
    if current_route[0,3] == '/en' || current_route[0,3] == '/es'
      current_route = current_route[3..-1]
    end
    @current_route = current_route
  end

  def set_alternate_route(alternate_route)
    @alternate_route = alternate_route
  end

  def get_alternate_route
    if @alternate_route.nil?
      @current_route
    else
      @alternate_route
    end
  end

  def self.instance
    @instance ||= new
  end
end
