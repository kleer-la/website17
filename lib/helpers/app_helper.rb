module AppHelper
  def truncate_words(text, max_words)
    words = text.split
    words[0..max_words].join(' ') + (words.size > max_words ? ' ...' : '')
  end

  def smart_truncate(text, max_length)
    return text if text.length <= max_length

    # Find the last space before max_length
    cutoff = text[0...max_length].rindex(' ') || max_length

    # Get everything up to the last space
    truncated = text[0...cutoff]

    # Remove any trailing punctuation
    truncated = truncated.sub(/[.,;:]$/, '')

    truncated + '...'
  end
end
