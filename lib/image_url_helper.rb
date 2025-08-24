module ImageUrlHelper
  def self.replace_s3_with_cdn(url)
    return url if url.nil? || url.empty?
    url.gsub('https://kleer-images.s3.sa-east-1.amazonaws.com', 'https://d3vnsn21cv5bcd.cloudfront.net')
  end
end