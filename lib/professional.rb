class Professional
  attr_accessor :name, :bio, :linkedin_url, :gravatar_picture_url, :twitter_username, :id,
                :surveyed_count

  def initialize(xml = nil, lang = 'es')
    @id =
      @name =
        @bio =
          @linkedin_url =
            @gravatar_picture_url =
              @twitter_username = ''.freeze
    load_xml(xml, lang) unless xml.nil?

    @surveyed_count = 0
  end

  def load_xml(xml, lang)
    bio_tag = lang == 'en' ? 'bio-en' : 'bio'
    @id = first_content(xml, 'id').to_i
    @name = xml.find_first('name').content
    @bio = first_content(xml, bio_tag)
    @linkedin_url = xml.find_first('linkedin-url').content
    @gravatar_picture_url = xml.find_first('gravatar-picture-url').content
    @twitter_username = xml.find_first('twitter-username').content
  end
end
