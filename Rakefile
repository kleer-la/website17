desc 'List defined routes'
task 'routes' do
  require './app'

  Sinatra::Application.routes.each_pair do |verb, route|
    v = ":: #{verb} ::"
    puts (' ' * (15 - v.length)) + v
    r = route.map { |path| path[0].to_s }
    r.sort
    r.each { |path| puts (' ' * 17) + path }
  end
end

desc 'Walk the site and report internal references that do not land on a 200 ' \
     '(rake crawl[https://qa.kleer.la])'
task :crawl, [:base_url, :max_pages] do |_t, args|
  require './lib/site_crawl'

  base = args[:base_url] || 'https://www.kleer.la'
  max = (args[:max_pages] || 400).to_i
  warn "Recorriendo #{base} (hasta #{max} páginas)..."
  crawl = SiteCrawl.new(base, max_pages: max, logger: ->(url) { warn "  #{url}" }).run
  puts crawl.report
end

desc 'Lighthouse rules and timings on a deployed site, optionally against a baseline ' \
     '(rake perf[https://qa.kleer.la,https://www.kleer.la])'
task :perf, [:base_url, :baseline_url] do |_t, args|
  usage = 'Usage: rake perf[https://qa.kleer.la] or rake perf[https://qa.kleer.la,https://www.kleer.la]'
  abort usage unless args[:base_url]

  env = { 'PERF_BASE_URL' => args[:base_url], 'PERF_BASELINE_URL' => args[:baseline_url].to_s }
  exit system(env, 'bundle', 'exec', 'rspec', 'spec/performance', '--format', 'documentation')
end
