require 'spec_helper'
require './app'

# The slugs of the old site carried accents, parentheses and capitals —
# 69-proyectos-ágiles-con-scrum, 377-design-thinking-workshop-(online),
# 102-contratos-Agiles. The route patterns accept [a-z0-9_-] only, so every one
# of them 404s, and eleven of the twenty-five URLs the index report lists as not
# found are exactly that.
#
# Nothing but the leading id is read (`slug.split('-')[0]`), so the rest of the
# slug is decoration: letting those characters through is enough for the course
# to be found and, where it was renamed, for its own redirect to take over.
describe 'a course asked for by its old slug' do
  def app
    Sinatra::Application.new
  end

  before do
    allow(Page).to receive(:load_from_keventer).and_return(Page.new)
    allow(Category).to receive(:create_keventer_json).and_return([])
    allow(EventType).to receive(:create_keventer_json).and_return(nil)
  end

  # `create_keventer_json` is stubbed to nil, so a matched route ends in the
  # catalogue redirect. That is the signal we want: it says the pattern matched
  # and the id was read. A 404 says the route never matched at all.
  def matched?(last_response)
    last_response.status == 302 || last_response.status == 301
  end

  # Percent-encoded, because that is what arrives: a raw multibyte character is
  # not legal in a request line, and every client escapes it before sending.
  {
    'accents' => '/es/cursos/69-proyectos-%C3%A1giles-con-scrum',
    'parentheses' => '/es/cursos/377-design-thinking-workshop-(online)',
    'capitals' => '/es/cursos/102-contratos-Agiles',
    'accents and parentheses' =>
      '/es/cursos/131-taller-de-facilitaci%C3%B3n-gr%C3%A1fica-(m%C3%B3dulos-1-y-2)',
    'an unprefixed legacy path' => '/es/cursos/154-taller-de-pr%C3%A1cticas-devops'
  }.each do |what, path|
    it "matches a slug with #{what}" do
      get path

      expect(matched?(last_response)).to be(true), "#{path} answered #{last_response.status}"
    end
  end

  it 'matches an old category URL with an accented slug' do
    get '/es/categoria/organizaciones/cursos/268-proyectos-%C3%A1giles-con-scrum-(online)'

    expect(last_response.status).to eq 301
    expect(last_response.headers['Location']).to include '/es/cursos/268-'
  end

  # The junk stays dead: a path with no id in front is not a course URL.
  it 'still 404s a slug that names no course' do
    get '/es/formacion/Agile'

    expect(last_response.status).to eq 404
  end
end
