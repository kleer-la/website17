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
        .to eq(anchor: 'que-es-kanban-y-para-que-sirve', label: '¿Qué es Kanban?')
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
end
