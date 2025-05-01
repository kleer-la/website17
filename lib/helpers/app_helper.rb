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

  def section_data(page, section_key, defaults = {})
    return defaults if page.nil? || page.sections.nil? || page.sections[section_key].nil?
    symbolized_section = page.sections[section_key].transform_keys(&:to_sym).reject { |_, value| value == "" }
    defaults.merge(symbolized_section || {})
  end

  module_function

  def boolean_value(value)
    return false if value.nil? || value.to_s.empty?
    ['true', '1', 'yes'].include?(value.to_s.downcase)
  end  
end
