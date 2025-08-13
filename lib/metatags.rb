module MetaTags
  class Tags
    # @_tags = nil

    # def self.meta_tags!(...)
    #   @_tags = Tags.new if @_tags.nil?
    #   @_tags.set(...)
    # end

    # def self.display_meta_tags(...)
    #   meta_tags!(...)
    #   head = @_tags.display
    #   @_tags = nil
    #   head
    # end

    # default values
    def initialize
      @tags = {
        charset: 'utf-8',
        base_url: 'https://www.kleer.la',
        'http-equiv': ['X-UA-Compatible', 'IE=edge'],
        viewport: 'width=device-width, initial-scale=1.0"',
        image: 'https://www.kleer.la/img/logos/kleer.png',
        hreflang: %i[es en]
      }
      @path = ''
      @shown = false
    end

    def set!(keyw = {})
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

    def path
      @path = @tags[:path]

      if @path
        if @path.include? '/es'
          @path.slice!('/es')
        elsif @path.include? '/en'
          @path.slice!('/en')
        end
      end

      @tags.delete :path
    end

    def alternate_paths
      @alternate_paths = @tags[:alternate_paths]
      @tags.delete :alternate_paths
    end

    def current_lang
      @current_lang = @tags[:current_lang]
      @tags.delete  :current_lang
    end

    def display(...)
      return '' if @shown

      set!(...)

      @shown = true
      robot
      site
      current_lang
      path
      alternate_paths
      # @tags.delete :hreflang if !!@tags[:canonical]
      (@tags.map { |tag| display_one tag }).join('')
    end

    def display_one(tag)
      case tag[0]
      when :'http-equiv'
        "<meta http-equiv=\"#{tag[1][0]}\" content=\"#{tag[1][1]}\"/>" if tag[1]
      when :robot
        "<meta name=\"robots\" content=\"#{tag[1]}\"/>" if tag[1]
      when :viewport
        "<meta name=\"viewport\" content=\"#{tag[1]}\"/>" if tag[1]
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
        "<link rel=\"canonical\" href=\"#{@base_url}/#{@current_lang}#{tag[1]}\"/>"
      when :hreflang
        unless @path.nil?
          # Use alternate paths if provided, otherwise use same path for both languages
          es_path = @alternate_paths&.dig(:es) || @path
          en_path = @alternate_paths&.dig(:en) || @path
          
          tag[1].reduce(tag[1] != [] ? "<link rel=\"alternate\" hreflang='x-default' href=\"#{@base_url}/es#{es_path}\"/>" : '') do |ac, current_lang|
            path_for_lang = case current_lang
            when :es
              es_path
            when :en
              en_path
            else
              @path
            end
            ac + "<link rel=\"alternate\" hreflang=\"#{current_lang}\" href=\"#{@base_url}/#{current_lang}#{path_for_lang}\"/>"
          end
        end
      when :image
        unless tag[1] == ''
          ''"
          <meta property=\"og:image\" content=\"#{tag[1]}\"/>
          <meta property=\"og:image:url\" content=\"#{tag[1]}\"/>
          <meta property=\"og:image:secure_url\" content=\"#{tag[1]}\"/>
          "''
        end
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
