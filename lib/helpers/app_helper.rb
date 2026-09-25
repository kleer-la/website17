module AppHelper
  def truncate_words(text, max_words)
    return '' if text.empty?

    words = text.split(/\s+/)
    return text if words.length <= max_words

    words[0...max_words].join(' ') + ' ...'
  end

  def smart_truncate(text, max_length)
    text ||= ''
    return text if text.length <= max_length

    # Find the last space before max_length
    cutoff = text[0...max_length].rindex(' ') || max_length

    # Get everything up to the last space and trim any trailing whitespace
    truncated = text[0...cutoff].strip

    # Remove any trailing punctuation, but only if it's the last character
    truncated = truncated.sub(/[.,;:]$/, '')

    truncated + '...'
  end

  def to_lines(text)
    words = text.split(/\s+/).reject(&:empty?)
    total_words = words.length
    result = ['', '', '']
    if total_words == 0
      return result
    elsif total_words <= 3
      # Put one word per line up to 3 words
      words.each_with_index do |word, index|
        result[index] = word
      end
      return result
    end

    words_per_line = (total_words / 3.0)
    first_cut = words_per_line.round
    second_cut = (2 * words_per_line).round

    result[0] = words[0...first_cut].join(' ')
    second_slice = words[first_cut...second_cut]
    result[1] = second_slice.empty? ? '' : second_slice.join(' ')
    third_slice = words[second_cut..-1]
    result[2] = third_slice.empty? ? '' : third_slice.join(' ')

    result
  end

  # One anchor per FAQ question, made from its text ("¿Qué es Kanban y para qué
  # sirve?" -> "que-es-kanban-y-para-que-sirve") so a link survives reordering;
  # a repeated question gets -2, -3... to keep the ids unique on the page.
  def faq_anchors(questions)
    seen = Hash.new(0)
    questions.map do |question|
      base = anchor_slug(question)
      base = 'pregunta' if base.empty?
      seen[base] += 1
      seen[base] == 1 ? base : "#{base}-#{seen[base]}"
    end
  end

  # "¿Qué es [un|la…] X [y para/por qué …]?" — the FAQ questions that define a term.
  FAQ_DEFINITION = /\A\s*¿?\s*qu[ée]\s+(?:es|son)\s+(?:(?:el|la|los|las|un|una)\s+)?(?<term>.+?)
                    (?<tail>\s+y\s+(?:para|por)\s+qu[ée]\b.*)?\s*\?*\s*\z/xim

  # The terms a page's FAQ defines, keyed by their slug, each with the anchor of
  # its question and a link label that repeats the question up to the term
  # ("¿Qué es Kanban?"). A program step named like a term links to it.
  def faq_definitions(faq)
    questions = Array(faq).map { |question, _| question.to_s.gsub(/<[^>]*>/, '').strip }
    anchors = faq_anchors(questions)
    questions.each_with_index.with_object({}) do |(question, index), found|
      match = FAQ_DEFINITION.match(question)
      next unless match

      found[anchor_slug(match[:term])] ||= { anchor: anchors[index], label: definition_label(question, match) }
    end
  end

  # The question up to its term: "¿Qué es Kanban y para qué sirve?" -> "¿Qué es Kanban?"
  def definition_label(question, match)
    label = match[:tail] ? question[0...match.begin(:tail)] : question.sub(/\s*\?*\s*\z/, '')
    label = "¿#{label}" unless label.start_with?('¿')
    "#{label}?"
  end

  # The definition a program step links to: its whole title must be the term.
  def faq_definition_for(step_title, definitions)
    definitions[anchor_slug(step_title)]
  end

  def anchor_slug(text)
    plain = text.to_s.gsub(/<[^>]*>/, '')
    I18n.transliterate(plain).downcase.gsub(/[^a-z0-9]+/, '-').gsub(/\A-+|-+\z/, '')
  end

  def section_data(page, section_key, defaults = {})
    return defaults if page.nil? || page.sections.nil? || page.sections[section_key].nil?

    symbolized_section = page.sections[section_key].transform_keys(&:to_sym).reject { |_, value| value == '' }
    defaults.merge(symbolized_section || {})
  end

  module_function

  def boolean_value(value)
    return false if value.nil? || value.to_s.empty?

    %w[true 1 yes].include?(value.to_s.downcase)
  end
end
