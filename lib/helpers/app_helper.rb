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
    words = text.split(/\s+/) # Split into words
    total_words = words.length
    words_per_line = (total_words.to_f / 3).ceil # Roughly equal parts
  
    [
      words.slice(0, words_per_line).join(' '),
      words.slice(words_per_line, words_per_line).join(' '),
      words.slice(words_per_line * 2, total_words).join(' ')
    ]
  end
  

  module_function

  def boolean_value(value)
    return false if value.nil? || value.to_s.empty?
    ['true', '1', 'yes'].include?(value.to_s.downcase)
  end  
end
