require 'bundler'
Bundler.setup

require 'derailed_benchmarks'
require 'derailed_benchmarks/tasks'

namespace :perf do
  task :rack_load do
    require_relative './app'
    DERAILED_APP = Sinatra::Application
  end
end

# bundle exec derailed exec perf:objects
# perf:mem_over_time
# /es/ (estable en 88MiB)
# /es/blog (estable en 63MiB)
# 
# /es/agenda (estable en 59MiB)
# /es/catalogo (estable en 99MiB)
#
# Muy rápido
# /es/agilidad-organizacional (estable en 92MiB)
#
# /es/somos (estable en 67MiB)
#
# Muy rápidos
# /es/prensa (estable en 55MiB)
# /es/clientes (estable en 56MiB)
# /es/recursos (estable en 56MiB)