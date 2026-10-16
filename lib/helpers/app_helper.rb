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

  # A course's rendered markdown is a run of <h4>title</h4> blocks (program steps,
  # FAQ questions): the [title, body] pairs, in order.
  def h4_blocks(html)
    html.to_s.split('<h4>').filter_map do |block|
      title, body = block.split('</h4>')
      [title, body] unless title.nil?
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

      found[anchor_slug(match[:term])] ||= { anchor: anchors[index], label: definition_label(question, match),
                                             term: match[:term].strip }
    end
  end

  # The question up to its term: "¿Qué es Kanban y para qué sirve?" -> "¿Qué es Kanban?"
  def definition_label(question, match)
    label = match[:tail] ? question[0...match.begin(:tail)] : question.sub(/\s*\?*\s*\z/, '')
    label = "¿#{label}" unless label.start_with?('¿')
    "#{label}?"
  end

  # The question definitions of a course's FAQ, read once per page.
  def course_faq_definitions
    @course_faq_definitions ||= faq_definitions(h4_blocks(@markdown_renderer.render(@event_type.faq.to_s)))
  end

  # A course text with its first mention of each term the FAQ defines linked to
  # that question; a term is linked once in the whole page, across texts.
  def link_course_terms(html)
    link_faq_terms(html, course_faq_definitions, @linked_terms ||= Set.new)
  end

  FAQ_TERM_SKIPPED_IN = %w[a h1 h2 h3 h4 h5 h6 button script style].freeze

  # `used` holds the slugs already linked: the call adds the ones it links.
  def link_faq_terms(html, definitions, used)
    return html if definitions.empty? || html.to_s.strip.empty?

    fragment = Nokogiri::HTML::DocumentFragment.parse(html)
    definitions.sort_by { |_, definition| -definition[:term].length }.each do |slug, definition|
      next if used.include?(slug)

      node = fragment.xpath('.//text()').find do |text|
        linkable_text?(text) && term_span(text.content, definition[:term])
      end
      next unless node

      link_term_in(node, definition)
      used << slug
    end
    fragment.to_html
  end

  def linkable_text?(text)
    text.ancestors.none? { |ancestor| FAQ_TERM_SKIPPED_IN.include?(ancestor.name) }
  end

  def link_term_in(node, definition)
    from, length = term_span(node.content, definition[:term])
    content = node.content
    link = Nokogiri::XML::Node.new('a', node.document)
    link['class'] = 'faq-term-link'
    link['href'] = "##{definition[:anchor]}"
    link.content = content[from, length]
    node.add_next_sibling(Nokogiri::XML::Text.new(content[(from + length)..], node.document))
    node.add_next_sibling(link)
    node.content = content[0, from]
  end

  # Where `term` first appears in `text` as a whole word, ignoring case and
  # accents: [offset, length], or nil.
  def term_span(text, term)
    haystack = fold_accents(text)
    needle = fold_accents(term)
    offset = 0
    while (found = haystack.index(needle, offset))
      before = found.zero? ? '' : haystack[found - 1]
      after = haystack[found + needle.length] || ''
      return [found, needle.length] unless before.match?(/[[:alnum:]]/) || after.match?(/[[:alnum:]]/)

      offset = found + 1
    end
    nil
  end

  # Same length as the input, so offsets carry over to the original text.
  def fold_accents(text)
    text.each_char.map do |char|
      plain = I18n.transliterate(char).downcase
      plain.length == 1 ? plain : char.downcase
    end.join
  end

  # A long description would make a narrow, tall column beside the side image:
  # [the part that stays beside it, the rest for the full width], cut at the
  # first top-level heading that comes after a paragraph.
  def split_description(html)
    html = html.to_s
    nodes = Nokogiri::HTML::DocumentFragment.parse(html).children.to_a
    cut = description_cut_index(nodes)
    return [html, ''] unless cut

    [nodes[0...cut].map(&:to_html).join, nodes[cut..].map(&:to_html).join]
  end

  def description_cut_index(nodes)
    seen_paragraph = false
    nodes.index do |node|
      seen_paragraph ||= node.name == 'p'
      seen_paragraph && node.name.match?(/\Ah[1-6]\z/)
    end
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
