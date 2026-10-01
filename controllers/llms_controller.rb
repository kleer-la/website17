require './lib/llms_txt'

# /llms.txt (#439). Its opening paragraph is the SEO description of the
# Keventer page `llms`, editable there; without one, the organisation's own.
get '/llms.txt' do
  pass if @is_lab

  content_type 'text/plain', charset: 'utf-8'
  intro = Page.load_from_keventer('es', 'llms').seo_description.to_s
  intro = JsonLdHelper::ORGANIZATION.dig('description', 'es') if intro.strip.empty?

  LlmsTxt.new(intro:, areas: ServiceAreaV3.try_create_list_keventer(false),
              programs: ServiceAreaV3.try_create_list_keventer(true),
              courses: Catalog.create_keventer_json || [], resources: Resource.create_list_keventer).to_s
end
