require 'spec_helper'
require './lib/helpers/app_helper'

describe AppHelper do
  include AppHelper

  describe '#smart_truncate' do
    test_cases = [
      ['Hello World', 15, 'Hello World', 'returns original text if length is less than max_length'],
      ['This is a long sentence that needs truncating', 10, 'This is a...', 'truncates at word boundary'],
      ['ThisIsAVeryLongWordWithNoSpaces', 10, 'ThisIsAVer...', 'handles text with no spaces'],
      ['This sentence ends with a period. And continues', 34, 'This sentence ends with a period...',
       'truncates preserving period'],
      ['This sentence ends with a period. And continues', 33, 'This sentence ends with a...',
       'truncates without period at boundary'],
      ['This    has    multiple    spaces', 12, 'This    has...', 'preserves multiple spaces'],
      ['Exactly20Characters!', 20, 'Exactly20Characters!', 'handles exact length match'],
      ['', 10, '', 'handles empty string'],
      [nil, 10, '', 'handles nil input'],
      ['Text with spaces   ', 10, 'Text with...', 'handles trailing spaces'],
      ['This has a comma, semicolon; and period.', 19, 'This has a comma...', 'handles punctuation'],
      ['Hello 世界 World', 8, 'Hello...', 'handles unicode characters']
    ]

    test_cases.each do |input, max_length, expected_output, description|
      it description do
        expect(smart_truncate(input, max_length)).to eq expected_output
      end
    end
  end

  describe '#truncate_words' do
    test_cases = [
      ['One two three four five', 2, 'One two ...', 'truncates to specified word count'],
      ['One two three', 5, 'One two three', 'returns original if under word limit'],
      ['Word', 1, 'Word', 'handles single word'],
      ['', 5, '', 'handles empty string'],
      ['One   two     three', 2, 'One two ...', 'normalizes multiple spaces']
    ]

    test_cases.each do |input, max_words, expected_output, description|
      it description do
        expect(truncate_words(input, max_words)).to eq expected_output
      end
    end
  end

  describe '#to_lines' do
  test_cases = [
    [
      'Impulsamos el crecimiento de tu empresa', 
      ['Impulsamos el', 'crecimiento de', 'tu empresa'],
      'splits text into 3 parts with exact matches'
    ],
    [
      'One two three four five six', 
      ['One two', 'three four', 'five six'],
      'divides 6 words evenly into 3 lines'
    ],
    [
      'Short text example', 
      ['Short', 'text', 'example'],
      'handles text with exactly 3 words'
    ],
    [
      'This is a very long sentence that should be divided into three parts evenly', 
      ['This is a very long', 'sentence that should be', 'divided into three parts evenly'],
      'handles longer text with uneven distribution'
    ],
    [
      '', 
      ['', '', ''],
      'handles empty string'
    ],
    [
      'Single', 
      ['Single', '', ''],
      'handles single word'
    ],
    [
      'Two words', 
      ['Two', 'words', ''],
      'handles two words'
    ],
    [
      'Multiple    spaces    between words', 
      ['Multiple', 'spaces between', 'words'],
      'handles multiple spaces between words'
    ]
  ]
  
  test_cases.each do |input, expected_output, description|
    it description do
      expect(to_lines(input)).to eq expected_output
    end
  end
end
end
