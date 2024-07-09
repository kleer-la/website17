require 'spec_helper'
require 'i18n'

describe 'I18n translations' do
  it 'should have the same keys for all languages' do
    I18n.load_path = Dir['locales/*.yml']
    I18n.backend.load_translations

    languages = [:en, :es]  # Add more languages as needed
    translations = {}

    languages.each do |lang|
      I18n.locale = lang
      translations[lang] = I18n.backend.send(:translations)[lang]
    end

    reference_keys = flatten_keys(translations[languages.first])

    languages.each do |lang|
      lang_keys = flatten_keys(translations[lang])
      missing = reference_keys - lang_keys
      extra = lang_keys - reference_keys
      expect(lang_keys).to match_array(reference_keys),
        "#{missing.count} Missing keys in #{lang}: #{missing}\n" \
        "#{extra.count} Extra keys in #{lang}: #{extra}"
    end
  end
end

def flatten_keys(hash, prefix = '')
  hash.flat_map do |key, value|
    if value.is_a?(Hash)
      flatten_keys(value, "#{prefix}#{key}.")
    else
      "#{prefix}#{key}"
    end
  end
end
