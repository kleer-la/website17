module AppHelper
  def truncate_words(text, max_words)
    words = text.split
    words[0..max_words].join(' ') + (words.size > max_words ? ' ...' : '')
  end
end
