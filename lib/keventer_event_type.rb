require './lib/keventer_reader'     # to_boolean

class KeventerEventType
  attr_accessor :id, :name, :subtitle, :goal, :description, :recipients, :program, :duration, :faq,
                :elevator_pitch, :learnings, :takeaways, :include_in_catalog,
                :public_editions, :surveyed_count,
                :external_site_url, :slug, :canonical_slug, :deleted, :noindex,
                :categories

  def initialize
    @id = nil
    @name = @subtitle = @goal = @description = ''
    @recipients = @program = @faq = ''
    @duration = 0
    @elevator_pitch = @learnings = @takeaways = ''
    @include_in_catalog = false
    @public_editions = []

    @surveyed_count = 0
    @external_site_url = nil

    @categories = []
  end

  def uri_path
    "cursos/#{@slug}"
  end

  def canonical_url
    "cursos/#{@canonical_slug}" if @canonical_slug.to_s != ''
  end

  def load_string(xml, field)
    s = field.to_s.gsub('_', '-')
    element = xml.find_first(s)
    send("#{field}=", element.content) unless element.nil?
  end

  def load(xml_keventer_event)
    @id = xml_keventer_event.find_first('id').content.to_i
    @duration = xml_keventer_event.find_first('duration').content.to_i

    %i[name subtitle description learnings takeaways
       goal recipients program faq
       external_site_url elevator_pitch slug canonical_slug].each do |f|
      load_string(xml_keventer_event, f)
    end
    @include_in_catalog = to_boolean(xml_keventer_event.find_first('include-in-catalog').content)
    @deleted = to_boolean(xml_keventer_event.find_first('deleted')&.content)
    @noindex = to_boolean(xml_keventer_event.find_first('noindex')&.content)

    # @surveyed_count = xml_keventer_event.find_first('surveyed-count').content.to_i

    load_categories xml_keventer_event
  end

  def load_categories(xml_keventer_event)
    xml_keventer_event.find('//category').each do |category|
      categories << [
        category.find_first('id').content.to_i,
        category.find_first('codename').content
      ]
    end
  end
end
