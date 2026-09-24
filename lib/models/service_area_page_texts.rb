# The hero and contact texts of an area page come from the "service-area" Page
# shared by every area. An area can bring its own; what it leaves empty keeps
# the shared text.
module ServiceAreaPageTexts
  PAGE_TEXTS = %i[hero_cta_text hero_secondary_cta_text hero_secondary_cta_target hero_note
                  contact_title contact_cta_text].freeze

  attr_accessor(*PAGE_TEXTS)

  # The area's own text, or nil when it leaves it to the shared Page.
  def own_text(field)
    value = public_send(field).to_s.strip
    value.empty? ? nil : value
  end

  # The second hero button only makes sense with somewhere to go.
  def hero_secondary_cta?
    !own_text(:hero_secondary_cta_text).nil? && !own_text(:hero_secondary_cta_target).nil?
  end
end
