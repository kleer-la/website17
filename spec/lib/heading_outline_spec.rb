require 'spec_helper'
require './lib/heading_outline'

# Each example is a real page reduced to the markup that matters. Search engines
# read the h1..h6 as the page outline, so a heading at the wrong level silently
# moves a section under another one.
describe HeadingOutline do
  def problems(body)
    described_class.new("<html><body>#{body}</body></html>").problems
  end

  def rules(body)
    problems(body).map(&:rule).uniq
  end

  let(:hero) { '<section class="hero"><div><h1>Aceleramos la evolución organizacional</h1></div></section>' }

  describe 'a single h1' do
    it 'accepts a page with exactly one' do
      expect(problems(hero)).to be_empty
    end

    it 'reports a page without one' do
      expect(rules('<h2>Sólo secciones</h2>')).to include :main_heading
    end

    it 'reports a page with two' do
      expect(rules("#{hero}<h1>Otro título</h1>")).to include :main_heading
    end
  end

  describe 'no skipped levels' do
    # Area page, "forma recomendada": the section title comes from the template
    # as h2 and the steps come from Keventer content as h4.
    let(:recommended_way) do
      <<~HTML
        #{hero}
        <section id="forma-recomendada"><div class="container">
          <h2>Del diagnóstico a la autonomía</h2>
          <ul class="rw-steps">
            <li><div class="rw-step-body"><h4>Diagnóstico</h4></div></li>
            <li><div class="rw-step-body"><h4>Trabajo y ajuste continuo</h4></div></li>
          </ul>
        </div></section>
      HTML
    end

    it 'reports going down more than one level' do
      skips = problems(recommended_way).select { _1.rule == :skipped_level }

      expect(skips.map { _1.heading.text }).to eq ['Diagnóstico']
      expect(skips.first.to_s).to include 'h4', 'h2'
    end

    it 'accepts the steps one level below their section' do
      expect(problems(recommended_way.gsub('h4>', 'h3>'))).to be_empty
    end

    it 'accepts going back up any number of levels' do
      expect(problems("#{hero}<section><h2>A</h2><h3>B</h3><h4>C</h4></section><section><h2>D</h2></section>"))
        .to be_empty
    end
  end

  describe 'no empty headings' do
    it 'reports a heading without text' do
      expect(rules("#{hero}<section><h2> </h2></section>")).to include :empty
    end
  end

  describe 'heading levels follow the DOM' do
    # Home: the featured program is a third offering next to the two area
    # cards, but as an h2 it becomes a sibling of the section title and adopts
    # the cards that follow it.
    let(:home) do
      <<~HTML
        #{hero}
        <section id="homepage-service-areas" class="container">
          <div class="mb-4"><h2>Hacemos que la ejecución estratégica funcione</h2><p>Ayudamos…</p></div>
          <div class="mb-4"><a class="featured-program"><div class="row"><div class="col-lg-9">
            <h2>Adopción Organizacional de IA</h2>
          </div></div></a></div>
          <div class="row">
            <div class="col-12"><a class="card"><div class="card-body"><h3>Cambio Organizacional y Liderazgo</h3></div></a></div>
            <div class="col-12"><a class="card"><div class="card-body"><h3>Producto Digital</h3></div></a></div>
          </div>
        </section>
        <section class="institutional"><div class="container"><h2>Impulsamos el crecimiento empresarial</h2></div></section>
      HTML
    end

    it 'reports a heading that ranks as high as the title of the section it sits in' do
      nested = problems(home).select { _1.rule == :nested }

      expect(nested.map { _1.heading.text }).to eq ['Adopción Organizacional de IA']
      expect(nested.first.related.text).to eq 'Hacemos que la ejecución estratégica funcione'
    end

    it 'reports siblings that the outline turns into children' do
      adopted = problems(home).select { _1.rule == :adopted }

      expect(adopted.map { _1.heading.text }).to eq ['Cambio Organizacional y Liderazgo', 'Producto Digital']
      expect(adopted.map { _1.related.text }.uniq).to eq ['Adopción Organizacional de IA']
    end

    it 'accepts the featured program as a sibling of the cards' do
      fixed = home.sub('<h2>Adopción Organizacional de IA</h2>', '<h3>Adopción Organizacional de IA</h3>')

      expect(problems(fixed)).to be_empty
    end

    # Area page: the front cards come from Keventer content as h2, inside the
    # section titled "Tres frentes…".
    it 'reports cards that rank as high as their section title' do
      area = <<~HTML
        #{hero}
        <section id="servicios"><div class="container">
          <h2>Tres frentes para impulsar resultados</h2>
          <div class="svc2-cards">
            <article class="svc2-card"><h2>Estrategia y Product Management</h2></article>
            <article class="svc2-card"><h2>Flujo y mejora continua</h2></article>
          </div>
        </div></section>
      HTML

      expect(problems(area).select { _1.rule == :nested }.map { _1.heading.text })
        .to eq ['Estrategia y Product Management', 'Flujo y mejora continua']
    end

    # Service page: the case study comes from Keventer inside the target panel,
    # which shares its section with the FAQ, so the section has no single title.
    it 'reports a heading that ranks as high as the one heading its block' do
      service = <<~HTML
        #{hero}
        <section><div class="container">
          <div class="svc2-panel"><h2>¿A quién está dirigido?</h2>
            <div class="svc2-prose"><div class="trix-content"><ul><li>Equipos</li></ul><h2>Un caso: banca digital</h2></div></div>
          </div>
          <div class="faq"><h3>Preguntas frecuentes</h3></div>
        </div></section>
      HTML

      nested = problems(service).select { _1.rule == :nested }
      expect(nested.map { [_1.heading.text, _1.related.text] })
        .to eq [['Un caso: banca digital', '¿A quién está dirigido?']]
    end

    # Footer titles are h5 right after the last section's h2: they end up as
    # children of whatever section happens to come last.
    it 'reports headings outside the block of the heading that adopts them' do
      page = <<~HTML
        #{hero}
        <section><div class="container"><h2>Empecemos por entender tu caso</h2></div></section>
        <footer><div class="col"><h3>Qué hacemos</h3></div></footer>
      HTML

      expect(rules(page)).to eq [:adopted]
    end

    it 'accepts a title in its own header block followed by the content it introduces' do
      page = "#{hero}<section><header><h2>Preguntas frecuentes</h2></header>" \
             '<div><div><h3>¿Cuánto dura?</h3></div></div></section>'

      expect(problems(page)).to be_empty
    end

    # Blog and resource bodies come from Keventer as flat rich text.
    it 'accepts flat markup, where a heading owns what follows it' do
      page = "#{hero}<article><h2>Qué es</h2><p>…</p><h3>Origen</h3><p>…</p><h2>Cómo se usa</h2><p>…</p></article>"

      expect(problems(page)).to be_empty
    end

    # Agenda: a section that is only a grid of cards has no title to outrank.
    it 'accepts a section of cards without a title' do
      page = <<~HTML
        #{hero}
        <section><h2>Próximas ediciones en vivo</h2>
          <div><a><h3>Agilidad primeros pasos</h3></a></div>
          <div><a><h3>Fundamentos de Lean y Kanban</h3></a></div>
        </section>
        <section><div class="row">
          <div class="col"><a><h3>Diseño Organizacional Ágil</h3></a></div>
          <div class="col"><a><h3>Equipos Ágiles con Scrum</h3></a></div>
        </div></section>
      HTML

      expect(rules(page)).not_to include :nested
    end
  end
end
