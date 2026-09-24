# The hero and contact texts of an area page come from the "service-area" Page
# shared by every area. An area can bring its own; what it leaves empty keeps
# the shared text.
module ServiceAreaPageTexts
  PAGE_TEXTS = %i[hero_cta_text hero_secondary_cta_text hero_secondary_cta_target hero_note
                  contact_title contact_text contact_cta_text].freeze

  attr_accessor(*PAGE_TEXTS)

  # The area's own text, or nil when it leaves it to the shared Page.
  def own_text(field)
    value = public_send(field).to_s.strip
    value.empty? ? nil : value
  end

  # The locals of the contact block closing the page. With a contact_text the
  # area brings a title and the promise under it; without one, its
  # contact_title stays the block's only line, as it always was.
  def contact_locals(shared_text, shared_cta)
    button_text = own_text(:contact_cta_text) || shared_cta
    text = own_text(:contact_text)
    return { contact_text: own_text(:contact_title) || shared_text, button_text: button_text } if text.nil?

    { contact_title: own_text(:contact_title), contact_text: text, button_text: button_text }
  end

  # The second hero button only makes sense with somewhere to go.
  def hero_secondary_cta?
    !own_text(:hero_secondary_cta_text).nil? && !own_text(:hero_secondary_cta_target).nil?
  end
end
