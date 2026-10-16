require 'spec_helper'
require './app'

# kleer-la/website17#424: a program step named like a "¿Qué es…?" question of
# the page's FAQ links to it, so the content does not write the link by hand.
describe AppHelper do
  include AppHelper

  describe '#faq_definitions' do
    def definitions(*questions)
      faq_definitions(questions.map { |question| [question, 'Respuesta'] })
    end

    it 'takes the term out of a "¿Qué es X y para qué sirve?" question' do
      expect(definitions('¿Qué es Kanban y para qué sirve?')['kanban'])
        .to eq(anchor: 'que-es-kanban-y-para-que-sirve', label: '¿Qué es Kanban?', term: 'Kanban')
    end

    it 'drops the article, and reads "son" and "por qué" the same way' do
      found = definitions('¿Qué es un Opportunity Solution Tree y para qué sirve?',
                          '¿Qué son las métricas DORA y para qué sirven?',
                          '¿Qué es la tríada de producto y por qué trabajamos con ella?')

      expect(found.keys).to eq(%w[opportunity-solution-tree metricas-dora triada-de-producto])
      expect(found['metricas-dora'][:label]).to eq('¿Qué son las métricas DORA?')
    end

    it 'takes a bare "¿Qué es X?" too' do
      expect(definitions('¿Qué es Lean?')['lean'][:anchor]).to eq('que-es-lean')
    end

    it 'ignores questions that define nothing' do
      expect(definitions('¿Sirve si el equipo ya usa Scrum?', '¿Cuánto dura?')).to be_empty
    end

    it 'points at the same anchor the FAQ gives a repeated question' do
      found = definitions('¿Cuánto dura?', '¿Qué es Lean?', '¿Cuánto dura?')

      expect(found['lean'][:anchor]).to eq('que-es-lean')
    end
  end

  describe '#faq_definition_for' do
    let(:found) { faq_definitions([['¿Qué es Toyota Kata y para qué sirve?', 'Un método']]) }

    it 'matches a step title to a term regardless of accents and capitals' do
      expect(faq_definition_for('TOYOTA KATA', found)[:anchor]).to eq('que-es-toyota-kata-y-para-que-sirve')
    end

    it 'does not match a title that only contains the term' do
      expect(faq_definition_for('Toyota Kata en la práctica', found)).to be_nil
    end
  end

  # The text of a course names a term its FAQ defines ("la teoría de restricciones
  # dice…"): the first mention links to the question, so nobody writes it by hand.
  describe '#link_faq_terms' do
    let(:found) do
      faq_definitions([['¿Qué es la teoría de restricciones?', 'R'], ['¿Qué es Scrum y para qué sirve?', 'R']])
    end

    def linked(html, used = Set.new) = link_faq_terms(html, found, used)

    it 'links the first mention of a defined term, whatever its case or accents' do
      expect(linked('<p>La Teoria de Restricciones dice mucho. La teoría de restricciones, también.</p>'))
        .to eq('<p>La <a class="faq-term-link" href="#que-es-la-teoria-de-restricciones">Teoria de Restricciones</a> ' \
               'dice mucho. La teoría de restricciones, también.</p>')
    end

    it 'links each term once, and tells the caller which ones it used' do
      used = Set.new
      linked('<p>Scrum y la teoría de restricciones.</p>', used)

      expect(used).to eq(Set.new(%w[scrum teoria-de-restricciones]))
      expect(linked('<p>Scrum otra vez.</p>', used)).to eq('<p>Scrum otra vez.</p>')
    end

    it 'leaves links and headings alone' do
      html = '<h2>Scrum</h2><p><a href="/x">Scrum</a> y Scrum.</p>'

      expect(linked(html)).to eq('<h2>Scrum</h2><p><a href="/x">Scrum</a> y ' \
                                 '<a class="faq-term-link" href="#que-es-scrum-y-para-que-sirve">Scrum</a>.</p>')
    end

    it 'only matches whole words' do
      expect(linked('<p>Scrumban no es Scrum.</p>')).to include('Scrumban no es <a')
    end

    it 'returns the text untouched when the FAQ defines nothing' do
      expect(link_faq_terms('<p>Scrum</p>', {}, Set.new)).to eq('<p>Scrum</p>')
    end
  end
end
