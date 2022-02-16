module MetaTags
  class Tags
    @_tags = nil

    def self.meta_tags!(...)
      @_tags = Tags.new if @_tags.nil?
      @_tags.set(...)
    end

    def self.display_meta_tags(...)
      meta_tags!(...)
      head = @_tags.display
      @_tags = nil
      head
    end

    # default values
    def initialize
      @tags = {
        charset: 'utf-8',
        base_url: ''
      }
    end

    def set(**keyw)
      @tags.merge! keyw
    end
    ROBOT_ATTR = %i[noindex nofollow noarchive].freeze
    def robot
      content = (
        (ROBOT_ATTR.map { |key| key.to_s if @tags[key] })
                      .filter { |elem| !elem.nil? }
      ).join(',')
      (@tags[:robot] = content) unless content.nil? || content == ''
      ROBOT_ATTR.each { |tag| @tags.delete tag }
    end

    def site
      @site = @tags[:site]
      @tags.delete :site
    end

    def display
      robot
      site
      (@tags.map { |tag| display_one tag }).join('')
    end

    def display_one(tag)
      case tag[0]
      when :robot
        "<meta name=\"robots\" content=\"#{tag[1]}\"/>" if tag[1]
      when :charset
        "<meta charset=\"#{tag[1]}\">" if tag[1].to_s.length.positive?
      when :title
        if tag[1].to_s.length.positive?
          tab = ''
          (tab += "#{@site} | ") if @site.to_s.length.positive?
          "<meta property=\"og:title\" content=\"#{tag[1]}\"/>
          <title>#{tab}#{tag[1]}</title>"
        end
      when :description
        if tag[1].to_s.length.positive?
          "<meta property=\"og:description\" content=\"#{tag[1]}\"/>
          <meta name=\"description\" content=\"#{tag[1]}\"/>"
        end
      when :base_url
        @base_url = tag[1]
        nil
      when :canonical
        "<link rel=\"canonical\" href=\"#{@base_url}/#{tag[1]}\"/>"
      else
        puts "(warning - MetaTag not used) #{tag[0]}: #{tag[1]} "
      end
    end
  end

  def meta_tags!(...)
    Tags.meta_tags!(...)
  end

  def display_meta_tags(...)
    Tags.display_meta_tags(...)
  end
end
