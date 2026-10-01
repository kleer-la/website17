require 'rack/utils'

# Links between the cards of a concepts resource, marked by hand in their text:
# [[slug]] links to that card and shows its name, [[slug|texto]] shows `texto`.
# Eventer checks the slugs when the card is saved (kleer-la/eventer#226); here
# a slug that is not a card, or the card itself, is shown as plain text. Every
# other character stays escaped, as the card fields always were (#433).
module ConceptLinkHelper
  CONCEPT_LINK_MARK = /\[\[([^\]|]+)(?:\|([^\]]*))?\]\]/

  def concept_text_html(resource, concept, text, base)
    concept_marks(text) do |plain, slug, label|
      next Rack::Utils.escape_html(plain) if plain

      target = resource.concept(slug)
      shown = Rack::Utils.escape_html(label || target&.name || slug)
      next shown if target.nil? || target.slug == concept.slug

      %(<a class="concepts-link" href="#{base}/#{Rack::Utils.escape_html(slug)}">#{shown}</a>)
    end
  end

  # Where a link does not fit: the meta description, the JSON-LD.
  def concept_plain_text(resource, text)
    concept_marks(text) { |plain, slug, label| plain || label || resource.concept(slug)&.name || slug }
  end

  private

  # Walks the text, yielding each stretch outside a mark as `plain`, and each
  # mark as its slug and its own text (nil when it has none).
  def concept_marks(text)
    text.to_s.split(/(\[\[[^\]]*\]\])/).map do |part|
      mark = part.match(/\A#{CONCEPT_LINK_MARK}\z/)
      next part.empty? ? '' : yield(part, nil, nil) unless mark

      label = mark[2].to_s.strip
      yield(nil, mark[1].strip, label.empty? ? nil : label)
    end.join
  end
end
