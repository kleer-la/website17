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

# Docs
# https://github.com/zombocom/derailed_benchmarks

# bundle exec derailed bundle:mem

# PATH_TO_HIT=/es/ bundle exec derailed exec perf:mem_over_time

# PATH_TO_HIT=/es/ bundle exec derailed exec perf:ips

# PATH_TO_HIT=/es/ bundle exec derailed exec perf:stackprof

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


# ./memory-test.sh perf:ips
# Endpoint: "/"
# Warming up --------------------------------------
#                  ips     1.000  i/100ms
# Calculating -------------------------------------
#                  ips      0.637  (± 0.0%) i/s -      3.000  in   5.222148s

# Endpoint: "/es/"
# Warming up --------------------------------------
#                  ips     1.000  i/100ms
# Calculating -------------------------------------
#                  ips      0.671  (± 0.0%) i/s -      3.000  in   5.174790s

# Endpoint: "/es/blog"
# Warming up --------------------------------------
#                  ips     1.000  i/100ms
# Calculating -------------------------------------
#                  ips      0.962  (± 0.0%) i/s -      5.000  in   5.199178s

# Endpoint: "/es/agenda"
# Warming up --------------------------------------
#                  ips     1.000  i/100ms
# Calculating -------------------------------------
#                  ips      1.758  (± 0.0%) i/s -      9.000  in   5.126877s

# Endpoint: "/es/catalogo"
# Warming up --------------------------------------
#                  ips     1.000  i/100ms
# Calculating -------------------------------------
#                  ips      0.386  (± 0.0%) i/s -      2.000  in   5.193602s

# Endpoint: "/es/agilidad-organizacional"
# Warming up --------------------------------------
#                  ips    12.000  i/100ms
# Calculating -------------------------------------
#                  ips    132.753  (± 9.8%) i/s -    660.000  in   5.019365s

# Endpoint: "/es/somos"
# Warming up --------------------------------------
#                  ips     1.000  i/100ms
# Calculating -------------------------------------
#                  ips      1.797  (± 0.0%) i/s -      9.000  in   5.048787s

# Endpoint: "/es/prensa"
# Warming up --------------------------------------
#                  ips    11.000  i/100ms
# Calculating -------------------------------------
#                  ips    115.628  (±12.1%) i/s -    572.000  in   5.035466s

# Endpoint: "/es/clientes"
# Warming up --------------------------------------
#                  ips    13.000  i/100ms
# Calculating -------------------------------------
#                  ips    142.120  (±10.6%) i/s -    702.000  in   5.000936s

# Endpoint: "/es/recursos"
# Warming up --------------------------------------
#                  ips    12.000  i/100ms
# Calculating -------------------------------------
#                  ips    120.469  (±10.8%) i/s -    600.000  in   5.050436s
 
# ./memory-test.sh perf:stackprof
# Endpoint: "/es/"
#        user     system      total        real
# 100 derailed requests  5.198676   0.227287   5.425963 (162.065440)
# ==================================
#   Mode: cpu(1000)
#   Samples: 516 (2.46% miss rate)
#   GC: 84 (16.28%)
# ==================================
#      TOTAL    (pct)     SAMPLES    (pct)     FRAME
#        168  (32.6%)          93  (18.0%)     LibXML::XML::Node#find
#         75  (14.5%)          75  (14.5%)     LibXML::XML::Node#context
#         64  (12.4%)          64  (12.4%)     (marking)
#         62  (12.0%)          51   (9.9%)     KeventerReader#parse
#         36   (7.0%)          34   (6.6%)     Tilt::Template#compile_template_method
#         20   (3.9%)          20   (3.9%)     (sweeping)
#         39   (7.6%)          19   (3.7%)     KeventerEventType#load_string
#         35   (6.8%)          16   (3.1%)     Erubis::Basic::Converter#convert_input
#         11   (2.1%)          11   (2.1%)     LibXML::XML::Parser.file
#         10   (1.9%)          10   (1.9%)     Tilt::Template#read_template_file

# Endpoint: "/es/blog"
#        user     system      total        real
# 100 derailed requests  1.358429   0.205879   1.564308 (139.303048)
# Running `stackprof tmp/2022-12-30T20:34:53+00:00-stackprof-cpu-myapp.dump`. Execute `stackprof --help` for more info
# ==================================
#   Mode: cpu(1000)
#   Samples: 150 (0.00% miss rate)
#   GC: 14 (9.33%)
# ==================================
#      TOTAL    (pct)     SAMPLES    (pct)     FRAME
#         21  (14.0%)          16  (10.7%)     Tilt::Template#compile_template_method
#         16  (10.7%)          16  (10.7%)     JSON.parse
#         22  (14.7%)          15  (10.0%)     Net::BufferedIO#rbuf_fill
#         10   (6.7%)          10   (6.7%)     (sweeping)
#          7   (4.7%)           7   (4.7%)     Timeout.timeout
#          7   (4.7%)           7   (4.7%)     BasicSocket#read_nonblock
#          9   (6.0%)           6   (4.0%)     Erubis::Basic::Converter#convert_input
#          5   (3.3%)           4   (2.7%)     Net::HTTPResponse.each_response_header
#          4   (2.7%)           4   (2.7%)     Tilt::Template#read_template_file
#          4   (2.7%)           4   (2.7%)     (marking)

# Endpoint: "/es/agenda"
#        user     system      total        real
# 100 derailed requests  1.743977   0.140606   1.884583 ( 58.205466)
# Running `stackprof tmp/2022-12-30T20:37:13+00:00-stackprof-cpu-myapp.dump`. Execute `stackprof --help` for more info
# ==================================
#   Mode: cpu(1000)
#   Samples: 176 (0.00% miss rate)
#   GC: 28 (15.91%)
# ==================================
#      TOTAL    (pct)     SAMPLES    (pct)     FRAME
#         29  (16.5%)          28  (15.9%)     Tilt::Template#compile_template_method
#         16   (9.1%)          16   (9.1%)     (marking)
#         12   (6.8%)          12   (6.8%)     (sweeping)
#          7   (4.0%)           7   (4.0%)     Event#load_date
#         11   (6.2%)           6   (3.4%)     Erubis::Basic::Converter#convert_input
#         12   (6.8%)           5   (2.8%)     Event#timezone_url
#          6   (3.4%)           5   (2.8%)     EventType#load_complete_event
#          4   (2.3%)           4   (2.3%)     Tilt::Template#read_template_file
#          4   (2.3%)           4   (2.3%)     Erubis::RubyGenerator#escape_text
#          4   (2.3%)           4   (2.3%)     I18n.interpolate_hash

# Endpoint: "/es/catalogo"
#        user     system      total        real
# 100 derailed requests 23.389988   0.371733  23.761721 (335.996487)
# Running `stackprof tmp/2022-12-30T20:38:13+00:00-stackprof-cpu-myapp.dump`. Execute `stackprof --help` for more info
# ==================================
#   Mode: cpu(1000)
#   Samples: 2250 (4.90% miss rate)
#   GC: 165 (7.33%)
# ==================================
#      TOTAL    (pct)     SAMPLES    (pct)     FRAME
#       1494  (66.4%)        1104  (49.1%)     LibXML::XML::Node#find
#        390  (17.3%)         390  (17.3%)     LibXML::XML::Node#context
#        446  (19.8%)         142   (6.3%)     KeventerEventType#load_string
#        108   (4.8%)         108   (4.8%)     (marking)
#        101   (4.5%)          91   (4.0%)     KeventerReader#parse
#         57   (2.5%)          57   (2.5%)     (sweeping)
#         47   (2.1%)          38   (1.7%)     Tilt::Template#compile_template_method
#         34   (1.5%)          34   (1.5%)     Object#to_boolean
#       1071  (47.6%)          20   (0.9%)     KeventerEventType#load_categories
#         24   (1.1%)          20   (0.9%)     EventType#load_complete_event

# Endpoint: "/es/agilidad-organizacional"
#        user     system      total        real
# 100 derailed requests  0.915226   0.009518   0.924744 (  0.925136)
# Running `stackprof tmp/2022-12-30T20:43:50+00:00-stackprof-cpu-myapp.dump`. Execute `stackprof --help` for more info
# ==================================
#   Mode: cpu(1000)
#   Samples: 92 (0.00% miss rate)
#   GC: 10 (10.87%)
# ==================================
#      TOTAL    (pct)     SAMPLES    (pct)     FRAME
#         28  (30.4%)          25  (27.2%)     Tilt::Template#compile_template_method
#         18  (19.6%)           8   (8.7%)     Erubis::Basic::Converter#convert_input
#          7   (7.6%)           7   (7.6%)     (sweeping)
#          5   (5.4%)           5   (5.4%)     Erubis::RubyGenerator#escape_text
#         28  (30.4%)           3   (3.3%)     Tilt::Cache#fetch
#          3   (3.3%)           3   (3.3%)     (marking)
#          7   (7.6%)           3   (3.3%)     I18n::Base#translate
#         30  (32.6%)           2   (2.2%)     Sinatra::Templates#compile_template
#          2   (2.2%)           2   (2.2%)     Erubis::Converter#detect_spaces_at_bol
#          2   (2.2%)           2   (2.2%)     Tilt::Template#read_template_file

# Endpoint: "/es/prensa"
#        user     system      total        real
# 100 derailed requests  0.927548   0.030032   0.957580 (  0.957948)
# Running `stackprof tmp/2022-12-30T20:46:38+00:00-stackprof-cpu-myapp.dump`. Execute `stackprof --help` for more info
# ==================================
#   Mode: cpu(1000)
#   Samples: 95 (0.00% miss rate)
#   GC: 13 (13.68%)
# ==================================
#      TOTAL    (pct)     SAMPLES    (pct)     FRAME
#         32  (33.7%)          29  (30.5%)     Tilt::Template#compile_template_method
#         10  (10.5%)          10  (10.5%)     (sweeping)
#         12  (12.6%)           7   (7.4%)     Erubis::Basic::Converter#convert_input
#         68  (71.6%)           4   (4.2%)     Sinatra::Templates#render
#         20  (21.1%)           3   (3.2%)     Tilt::Cache#fetch
#          3   (3.2%)           3   (3.2%)     Erubis::RubyGenerator#escape_text
#          3   (3.2%)           3   (3.2%)     (marking)
#          2   (2.1%)           2   (2.1%)     Tilt::Template#read_template_file
#          1   (1.1%)           1   (1.1%)     R18n::Loader::YAML#available
#          1   (1.1%)           1   (1.1%)     MetaTags::Tags#initialize

# Endpoint: "/es/clientes"
#        user     system      total        real
# 100 derailed requests  0.681686   0.050366   0.732052 (  0.732335)
# Running `stackprof tmp/2022-12-30T20:46:40+00:00-stackprof-cpu-myapp.dump`. Execute `stackprof --help` for more info
# ==================================
#   Mode: cpu(1000)
#   Samples: 72 (0.00% miss rate)
#   GC: 11 (15.28%)
# ==================================
#      TOTAL    (pct)     SAMPLES    (pct)     FRAME
#         18  (25.0%)          17  (23.6%)     Tilt::Template#compile_template_method
#          8  (11.1%)           8  (11.1%)     (sweeping)
#         22  (30.6%)           4   (5.6%)     Tilt::Template#compiled_method
#          9  (12.5%)           3   (4.2%)     Erubis::Basic::Converter#convert_input
#          3   (4.2%)           3   (4.2%)     Erubis::Converter#detect_spaces_at_bol
#          3   (4.2%)           3   (4.2%)     (marking)
#          3   (4.2%)           3   (4.2%)     Tilt::Template#read_template_file
#          3   (4.2%)           2   (2.8%)     R18n::Loader::YAML#available
#          3   (4.2%)           2   (2.8%)     Sinatra::Templates#find_template
#          3   (4.2%)           2   (2.8%)     Erubis::RubyGenerator#add_text

# Endpoint: "/es/recursos"
#        user     system      total        real
# 100 derailed requests  1.013754   0.010071   1.023825 (  1.024244)
# Running `stackprof tmp/2022-12-30T20:46:42+00:00-stackprof-cpu-myapp.dump`. Execute `stackprof --help` for more info
# ==================================
#   Mode: cpu(1000)
#   Samples: 101 (0.00% miss rate)
#   GC: 13 (12.87%)
# ==================================
#      TOTAL    (pct)     SAMPLES    (pct)     FRAME
#         26  (25.7%)          25  (24.8%)     Tilt::Template#compile_template_method
#          8   (7.9%)           8   (7.9%)     (sweeping)
#          5   (5.0%)           5   (5.0%)     (marking)
#         13  (12.9%)           4   (4.0%)     Erubis::Basic::Converter#convert_input
#          4   (4.0%)           4   (4.0%)     Erubis::RubyGenerator#escape_text
#         21  (20.8%)           3   (3.0%)     Tilt::Cache#fetch
#          3   (3.0%)           3   (3.0%)     Tilt::Template#read_template_file
#          2   (2.0%)           2   (2.0%)     Kernel#require
#          4   (4.0%)           2   (2.0%)     Rack::Session::Abstract::SessionHash#[]
#         61  (60.4%)           2   (2.0%)     Tilt::Template#render
