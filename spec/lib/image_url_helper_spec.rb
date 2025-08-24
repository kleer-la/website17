require_relative '../spec_helper'
require './lib/image_url_helper'

RSpec.describe ImageUrlHelper do
  describe '.replace_s3_with_cdn' do
    test_cases = [
      {
        input: 'https://kleer-images.s3.sa-east-1.amazonaws.com/image.jpg',
        expected: 'https://d3vnsn21cv5bcd.cloudfront.net/image.jpg',
        description: 'replaces S3 URLs with CloudFront CDN URLs'
      },
      {
        input: 'https://kleer-images.s3.sa-east-1.amazonaws.com/path/to/image.png',
        expected: 'https://d3vnsn21cv5bcd.cloudfront.net/path/to/image.png',
        description: 'replaces S3 URLs with paths'
      },
      {
        input: 'https://d3vnsn21cv5bcd.cloudfront.net/already-cdn.jpg',
        expected: 'https://d3vnsn21cv5bcd.cloudfront.net/already-cdn.jpg',
        description: 'returns existing CDN URLs unchanged'
      },
      {
        input: 'https://other-domain.com/image.jpg',
        expected: 'https://other-domain.com/image.jpg',
        description: 'returns other domain URLs unchanged'
      },
      {
        input: nil,
        expected: nil,
        description: 'returns nil when input is nil'
      },
      {
        input: '',
        expected: '',
        description: 'returns empty string when input is empty'
      }
    ]

    test_cases.each do |test_case|
      it test_case[:description] do
        result = ImageUrlHelper.replace_s3_with_cdn(test_case[:input])
        expect(result).to eq(test_case[:expected])
      end
    end
  end
end