require 'spec_helper'
require './app'
require './lib/heading_outline'

# The pages search engines rank us on, rendered from Keventer content shaped like
# production's, checked as the outline of headings they read (see HeadingOutline).
describe 'the heading outline of the main pages' do
  def app
    Sinatra::Application.new
  end

  def area_json
    JSON.parse(File.read('spec/fixtures/headings/area_producto_digital.json'))
  end

  def area(hash = area_json.merge('ordering' => 10))
    ServiceAreaV3.new.load_from_json(hash)
  end

  def outline_problems(path)
    get path
    expect(last_response.status).to eq 200
    HeadingOutline.new(last_response.body).problems.map(&:to_s)
  end

  def expect_sound_outline(path)
    problems = outline_problems(path)
    expect(problems).to be_empty, "#{problems.size} heading problems on #{path}:\n  #{problems.join("\n  ")}"
  end

  # Production lists the AI programme before the areas, which puts it inside
  # their section rather than in one of its own.
  let(:featured_program) do
    area('ordering' => 1, 'slug' => 'adopcion-organizacional-ia', 'name' => 'Adopción Organizacional de IA',
         'lang' => 'es', 'is_training_program' => true, 'primary_color' => '#FF5733', 'services' => [])
  end

  before do
    CacheService.instance.clear
    Toggle.turn(:services_redesign, true)
    allow(Page).to receive(:load_from_keventer).and_return(Page.new)
    allow(Event).to receive(:create_keventer_json).and_return([])
    other_area = area(area_json.merge('ordering' => 20, 'slug' => 'cambio', 'name' => 'Cambio'))
    allow(ServiceAreaV3).to receive(:try_create_list_keventer) do |programs = false|
      programs ? [featured_program] : [area, other_area]
    end
    allow(ServiceAreaV3).to receive(:create_keventer) do |slug|
      slug == featured_program.slug ? featured_program : area
    end
  end

  after { Toggle.turn(:services_redesign, false) }

  # Each page is pending with what still breaks its outline. Once a page is
  # fixed RSpec fails the pending example, which is the cue to drop the line.
  it 'home' do
    pending 'the featured programme is an h2 inside the areas section'
    expect_sound_outline('/es/')
  end

  it 'services' do
    pending 'the area titles are h2 inside the section that lists them'
    expect_sound_outline('/es/servicios')
  end

  it 'service area' do
    pending 'front cards are h2 in Keventer content; recommended-way steps and FAQ title are h4'
    expect_sound_outline('/es/servicios/producto-digital')
  end

  it 'service' do
    pending 'hero tagline is an h2; outcomes, program and FAQ titles are h4; ' \
            'the case study is an h2 in Keventer content'
    expect_sound_outline('/es/servicios/producto-digital/estrategia-product-management')
  end
end
