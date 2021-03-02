class KeventerEventType
  attr_accessor :id, :name, :subtitle, :goal, :description, :recipients, :program, :duration, :faqs,
                :elevator_pitch, :learnings, :takeaways, :elevator_pitch, :include_in_catalog,
                :public_editions, :average_rating, :net_promoter_score, :surveyed_count,
                :promoter_count, :external_site_url

  def initialize
    @id = nil
    @name = ""
    @subtitle= ""
    @goal = ""
    @description = ""
    @recipients = ""
    @program = ""
    @faqs = ""
    @duration = 0
    @elevator_pitch = ""
    @learnings = ""
    @takeaways = ""
    @include_in_catalog = false
    @public_editions = Array.new

    @average_rating = 0.0
    @net_promoter_score = 0
    @surveyed_count = 0
    @promoter_count = 0
    @external_site_url=nil
  end

  def uri_path
    @id.to_s + "-" + @name.downcase.gsub(/ /, "-")
  end

  def has_rate
    surveyed_count > 20 && !average_rating.nil?
  end

  def load_string(xml, field)
    element= xml.find_first(field.to_s)
    if not element.nil?
      send(field.to_s+"=", element.content)
    end
  end

  def load(xml_keventer_event)
    @id  = xml_keventer_event.find_first('id').content.to_i
    @duration = xml_keventer_event.find_first('duration').content.to_i

    [:name, :subtitle, :description, :learnings, :takeaways,
      :goal, :recipients, :program].each {
      |f| load_string(xml_keventer_event, f)
    }
    @external_site_url = xml_keventer_event.find_first('external-site-url')&.content
    @faqs  = xml_keventer_event.find_first('faq').content
    @elevator_pitch = xml_keventer_event.find_first('elevator-pitch').content
    @include_in_catalog = to_boolean( xml_keventer_event.find_first('include-in-catalog').content )

    @average_rating = xml_keventer_event.find_first('average-rating').content.nil? ? nil : xml_keventer_event.find_first('average-rating').content.to_f.round(2)
    @net_promoter_score = xml_keventer_event.find_first('net-promoter-score').content.nil? ? nil : xml_keventer_event.find_first('net-promoter-score').content.to_i
    @surveyed_count = xml_keventer_event.find_first('surveyed-count').content.to_i
    @promoter_count = xml_keventer_event.find_first('promoter-count').content.to_i
  end

  def categories
    data=      [
[ 102,3,"clientes"],
[ 103,2,"organizaciones"],
[ 104,2,"organizaciones"],
[ 10,5,"producto"],
[ 106,2,"organizaciones"],
[ 109,4,"software"],
[ 110,4,"software"],
[ 112,4,"software"],
[ 11,2,"organizaciones"],
[ 114,4,"software"],
[ 116,2,"organizaciones"],
[ 119,2,"organizaciones"],
[ 120,2,"organizaciones"],
[ 120,3,"clientes"],
[ 121,2,"organizaciones"],
[ 124,2,"organizaciones"],
[ 124,3,"clientes"],
[ 127,2,"organizaciones"],
[ 1,2,"organizaciones"],
[ 131,3,"clientes"],
[ 13,2,"organizaciones"],
[ 135,5,"producto"],
[ 136,2,"organizaciones"],
[ 140,5,"producto"],
[ 141,5,"producto"],
[ 145,4,"software"],
[ 14,5,"producto"],
[146,2,"organizaciones"],
[ 148,5,"producto"],
[ 149,4,"software"],
[ 151,4,"software"],
[ 15,2,"organizaciones"],
[ 153,2,"organizaciones"],
[ 15,3,"clientes"],
[ 154,4,"software"],
[ 155,2,"organizaciones"],
[ 160,2,"organizaciones"],
[ 162,5,"producto"],
[ 164,3,"clientes"],
[ 16,4,"software"],
[ 165,2,"organizaciones"],
[ 166,4,"software"],
[ 167,3,"clientes"],
[ 168,3,"clientes"],
[ 169,3,"clientes"],
[ 170,3,"clientes"],
[ 171,5,"producto"],
[ 172,5,"producto"],
[ 17,4,"software"],
[ 179,3,"clientes"],
[ 182,4,"software"],
[ 18,4,"software"],
[ 185,4,"software"],
[ 187,4,"software"],
[ 188,5,"producto"],
[ 189,3,"clientes"],
[193,3,"clientes"],
[ 194,2,"organizaciones"],
[ 19,4,"software"],
[ 196,2,"organizaciones"],
[ 197,2,"organizaciones"],
[ 198,2,"organizaciones"],
[ 199,2,"organizaciones"],
[ 201,5,"producto"],
[ 203,5,"producto"],
[ 20,4,"software"],
[ 205,4,"software"],
[ 206,5,"producto"],
[ 207,4,"software"],
[ 211,5,"producto"],
[ 21,2,"organizaciones"],
[ 21,3,"clientes"],
[ 215,4,"software"],
[ 216,2,"organizaciones"],
[ 217,4,"software"],
[ 221,2,"organizaciones"],
[ 223,3,"clientes"],
[ 224,4,"software"],
[ 22,4,"software"],
[ 226,4,"software"],
[ 229,5,"producto"],
[ 2,2,"organizaciones"],
[ 230,3,"clientes"],
[ 23,2,"organizaciones"],
[ 233,3,"clientes"],
[ 238,5,"producto"],
[ 240,4,"software"],
[ 242,3,"clientes"],
[ 246,4,"software"],
[ 247,3,"clientes"],
[ 249,3,"clientes"],
[ 250,2,"organizaciones"],
[ 25,2,"organizaciones"],
[ 255,2,"organizaciones"],
[ 256,3,"clientes"],
[ 258,2,"organizaciones"],
[ 259,2,"organizaciones"],
[ 26,2,"organizaciones"],
[ 264,2,"organizaciones"],
[ 265,2,"organizaciones"],
[ 266,2,"organizaciones"],
[ 268,2,"organizaciones"],
[ 29,2,"organizaciones"],
[ 302,4,"software"],
[ 303,3,"clientes"],
[ 31,3,"clientes"],
[ 32,3,"clientes"],
[ 33,2,"organizaciones"],
[ 337,2,"organizaciones"],
[ 338,3,"clientes"],
[ 339,3,"clientes"],
[ 340,5,"producto"],
[ 34,2,"organizaciones"],
[ 3,4,"software"],
[ 35,4,"software"],
[ 39,3,"clientes"],
[ 4,2,"organizaciones"],
[ 46,4,"software"],
[ 47,3,"clientes"],
[ 53,2,"organizaciones"],
[ 53,4,"software"],
[ 5,3,"clientes"],
[ 54,2,"organizaciones"],
[ 56,3,"clientes"],
[ 58,2,"organizaciones"],
[ 58,4,"software"],
[ 59,3,"clientes"],
[ 6,4,"software"],
[ 68,2,"organizaciones"],
[ 69,2,"organizaciones"],
[ 72,4,"software"],
[ 73,4,"software"],
[ 7,3,"clientes"],
[ 76,5,"producto"],
[ 78,4,"software"],
[ 80,4,"software"],
[ 81,5,"producto"],
[ 82,2,"organizaciones"],
[ 8,2,"organizaciones"],
[ 8,3,"clientes"],
[ 88,5,"producto"],
[ 89,3,"clientes"],
[ 89,4,"software"]
      ]

      (data.select { |t| t[0]==@id}
      ).map {|e| [e[1],e[2]]}
  end

end
