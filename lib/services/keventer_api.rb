require 'uri'

module KeventerAPI
  module_function

  def config
    @config ||= {
      base_url: ENV['KEVENTER_URL'] || 'https://eventos.kleer.la',
      api_path: '/api/'
    }
  end

  def url_for(path, params = {})
    config
    uri = URI.join(@config[:base_url], @config[:api_path], path.sub(%r{^/}, ''))
    uri.query = URI.encode_www_form(params) unless params.empty?
    uri.to_s
  end

  def echo(value)
    if ENV['RACK_ENV'] == 'test'
      caller_info = caller[1].match(/(.*):(\d+):in `([^']*)'/)
      file = caller_info[1]
      line = caller_info[2]
      method = caller_info[3]
      puts "----- #{method} (#{file}:#{line}) -->  #{value} -------"
    end
    value
  end

  # Define URL methods
  {
    events: 'events.json',
    resources: 'resources.json',
    kleerers: 'kleerers.json',
    categories: 'categories.json',
    catalog: 'catalog',
    news: 'news.json',
    podcasts: 'v3/podcasts',
    service_areas: 'service_areas.json',
    articles: 'articles.json',
    contacts: 'contacts',
    mailer: 'contact_us'
  }.each do |name, path|
    define_method("#{name}_url") { echo(url_for(path)) }
  end

  # Define parameterized URL methods
  {
    service_area: ['service_areas/:slug.json', :slug],
    service_area_preview: ['service_areas/:slug/preview.json', :slug],
    event_type: ['event_types/:id.json', :id],
    article: ['articles/:slug.json', :slug],
    resource: ['resources/:slug.json', :slug],
    assessment: ['assessments/:slug.json', :slug],
    contact_status: ['contacts/:id/status.json', :id]
  }.each do |name, (path, param)|
    define_method("#{name}_url") do |value|
      echo(url_for(path.gsub(":#{param}", value.to_s)))
    end
  end
  def page_url(lang, slug)
    s = "-#{slug}" unless slug.nil?
    url_for("pages/#{lang}#{s}")
  end
end
