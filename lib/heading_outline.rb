require 'nokogiri'

# Checks the h1..h6 of a rendered page as the outline search engines build from
# them. Headings come both from our templates and from HTML authored in
# Keventer, so a level that is right in isolation can still be wrong on the
# page: a card titled h2 inside a section titled h2 stops being part of it.
#
#   HeadingOutline.new(html).problems # => [Problem, ...]
class HeadingOutline
  LEVELS = %w[h1 h2 h3 h4 h5 h6].freeze
  SECTIONING = %w[section article aside nav].freeze

  Heading = Struct.new(:node, :level, :text) do
    def to_s
      "h#{level} «#{text[0, 60]}»"
    end
  end

  Problem = Struct.new(:rule, :heading, :related) do
    def to_s
      case rule
      when :main_heading then "#{heading}: the page should have exactly one h1"
      when :skipped_level then "#{heading} comes right after #{related}, skipping a level"
      when :empty then "#{heading} has no text"
      when :nested then "#{heading} is inside the section titled #{related} but does not rank below it"
      when :adopted then "#{heading} becomes a child of #{related} without being inside its block"
      end
    end
  end

  def initialize(html)
    @headings = Nokogiri::HTML5(html).css(LEVELS.join(',')).map do |node|
      Heading.new(node, node.name[1].to_i, node.text.split.join(' '))
    end
  end

  def problems
    main_heading + skipped_levels + empty + nested + adopted
  end

  private

  def main_heading
    h1s = @headings.select { _1.level == 1 }
    return [] if h1s.size == 1

    [Problem.new(:main_heading, h1s[1] || Heading.new(nil, 1, "#{h1s.size} found"))]
  end

  # Going down h2 -> h4 leaves a gap; going back up any number of levels is fine.
  def skipped_levels
    @headings.each_cons(2).filter_map do |previous, heading|
      Problem.new(:skipped_level, heading, previous) if heading.level > previous.level + 1
    end
  end

  def empty
    @headings.select { _1.text.empty? }.map { Problem.new(:empty, _1) }
  end

  # A section's title is its first heading, provided it is also the least
  # nested one. Everything else inside the section has to rank below it.
  # Sections of cards with no title of their own are left alone.
  def nested
    sections = @headings.flat_map { |h| sectioning_ancestors(h) }.uniq
    found = sections.flat_map do |section|
      title, *rest = @headings.select { inside?(_1, section) }
      next [] unless title && rest.all? { depth(_1, section) > depth(title, section) }

      rest.select { _1.level <= title.level }.map { Problem.new(:nested, _1, title) }
    end
    found.uniq { _1.heading.node }
  end

  # The outline makes each heading a child of the closest earlier heading with
  # a higher rank. That parent's block has to contain it in the DOM; otherwise
  # a sibling in the page has become a child in the outline.
  def adopted
    @headings.each_with_index.filter_map do |heading, i|
      parent = @headings[0...i].reverse.find { _1.level < heading.level }
      next if parent.nil? || within_block?(heading, parent)

      Problem.new(:adopted, heading, parent)
    end
  end

  # In flat markup (<h2/><p/><h3/>) a heading has no wrapper of its own: its
  # block is what follows it, up to the next heading of its rank or higher.
  def within_block?(heading, parent)
    block = block_of(parent)
    return heading.node.ancestors.include?(block) unless block == parent.node

    block.parent == heading.node.parent || heading.node.ancestors.include?(block.parent)
  end

  # The largest ancestor of a heading that holds no other heading of its rank or higher.
  def block_of(heading)
    @blocks ||= {}
    @blocks[heading.node] ||= begin
      block = heading.node
      heading.node.ancestors.each do |ancestor|
        break if !ancestor.element? || rival_inside?(heading, ancestor)

        block = ancestor
      end
      block
    end
  end

  def rival_inside?(heading, element)
    @headings.any? { _1.node != heading.node && _1.level <= heading.level && inside?(_1, element) }
  end

  def sectioning_ancestors(heading)
    heading.node.ancestors.select { SECTIONING.include?(_1.name) }
  end

  def inside?(heading, element)
    heading.node.ancestors.include?(element)
  end

  def depth(heading, section)
    heading.node.ancestors.take_while { _1 != section }.size
  end
end
