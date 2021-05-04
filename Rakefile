desc 'List defined routes'
task 'routes' do
    require './app'

  Sinatra::Application.routes.each_pair do |verb, route|
    v= ":: #{verb} ::"
    puts (" " * (15-v.length)) + v  
    r= route.map {|path| path[0].to_s}
    r.sort
    r.each {|path| puts (" " * 17) + path }
  end

end