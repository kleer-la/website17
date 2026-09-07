class SiteCrawl
  # Grouped by target, because one bad URL is usually named from many pages and
  # the fix is one place, not one per source.
  class Report
    SOURCES_SHOWN = 3

    def initialize(findings, pages)
      @findings = findings
      @pages = pages
    end

    def to_s
      return "Sin referencias internas rotas en #{@pages} páginas.\n" if @findings.empty?

      ([summary] + ordered.map { |finding| lines_for(finding) }).join("\n")
    end

    def summary
      "#{@findings.sum { |f| f.references.size }} referencias a #{@findings.size} URLs, " \
        "en #{@pages} páginas recorridas\n"
    end

    def ordered
      @findings.sort_by { |f| [-f.references.size, f.target] }
    end

    def lines_for(finding)
      destination = " → #{path_of(finding.location)}" if finding.location
      header = "#{path_of(finding.target)}  #{finding.status}#{destination}"
      [header, *finding.references.group_by(&:kind).map { |kind, refs| "    #{kind}: #{sources(refs)}" }].join("\n")
    end

    def sources(refs)
      paths = refs.map { |ref| path_of(ref.source) }.uniq
      shown = paths.first(SOURCES_SHOWN).join(', ')
      paths.size > SOURCES_SHOWN ? "#{shown} (+#{paths.size - SOURCES_SHOWN})" : shown
    end

    def path_of(url)
      return url if url.nil?

      URI.parse(url).request_uri
    rescue URI::Error
      url
    end
  end
end
