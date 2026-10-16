require 'spec_helper'
require './app'

# A course that stops being sold keeps its page as a notice, with no program,
# audience or takeaways. A section with nothing to say must not render its
# heading over an empty block.
describe 'GET /es/cursos/:slug — sections' do
  def app
    Sinatra::Application.new
  end

  let(:course) do
    { 'description' => 'Un curso', 'takeaways' => 'Te llevás **mucho**', 'recipients' => 'Equipos',
      'program' => "#### Kanban\n\nFlujo visible\n\n#### Retrospectiva\n\nMejora continua",
      'faq' => "#### ¿Qué es Kanban y para qué sirve?\n\nUn método.\n\n#### ¿Cuánto dura?\n\nDos días." }
  end

  def visit(overrides = {})
    allow(EventType).to receive(:create_keventer_json).and_return(
      EventType.new({ 'id' => 7, 'slug' => '7-csm', 'canonical_slug' => '7-csm', 'name' => 'CSM', 'lang' => 'es',
                      'deleted' => false, 'noindex' => false, 'elevator_pitch' => 'Scrum', 'categories' => [],
                      'trainers' => [] }.merge(course, overrides))
    )
    get '/es/cursos/7-csm'
    last_response.body
  end

  it 'renders every section when the course has content' do
    body = visit

    expect(body).to include('id="course-learnings"', 'id="course-recipients"', 'id="course-program"')
  end

  %w[takeaways recipients program].each do |field|
    section = { 'takeaways' => 'course-learnings', 'recipients' => 'course-recipients',
                'program' => 'course-program' }.fetch(field)

    [nil, '', "  \r\n "].each do |blank|
      it "hides #{section} when #{field} is #{blank.inspect}" do
        expect(visit(field => blank)).not_to include(%(id="#{section}"))
      end
    end
  end

  context 'with a FAQ that defines a term' do
    it 'links the program step named like the term to its question' do
      body = visit

      expect(body).to include('href="#que-es-kanban-y-para-que-sirve"', '¿Qué es Kanban?')
      expect(body.scan('class="program-definition"').size).to eq(1)
    end

    it 'anchors each question so the link lands on it' do
      body = visit

      expect(body).to include('id="que-es-kanban-y-para-que-sirve"', 'id="cuanto-dura"')
      expect(body).to include('/js/faq-anchors.js')
    end

    it 'adds no link when the FAQ does not define the step' do
      body = visit('faq' => "#### ¿Cuánto dura?\n\nDos días.")

      expect(body).not_to include('program-definition')
    end
  end
end
