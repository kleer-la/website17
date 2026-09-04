# Small view helpers for the Kleer Lab subdomain. Replaces the old Rails
# `render "shared/section"` block-partial (Sinatra ERB has no block-capturing
# partials) with a plain header builder that ported views wrap inline.
# Auto-registered as a Sinatra helper (module name ends with "Helper").
module LabViewHelper
  # Renders the <header> of a marketing section. `title`/`subtitle` accept
  # static HTML from this repo only (decorative <span>) — never user input.
  def lab_section_header(label:, title:, subtitle: nil, size: :md)
    mb, title_class = case size
                      when :sm then ['mb-12', 'text-3xl md:text-4xl font-headline font-bold tracking-tight']
                      when :lg then ['mb-20',
                                     'text-4xl md:text-6xl font-headline font-bold tracking-tighter leading-[1]']
                      else ['mb-16', 'text-4xl md:text-5xl font-headline font-bold tracking-tight']
                      end
    header_class = subtitle ? "#{mb} max-w-3xl" : mb
    h2_class = subtitle ? "#{title_class} mb-6" : title_class

    html = +%(<header class="#{header_class}">)
    html << %(<p class="font-label text-xs uppercase tracking-[0.3em] text-secondary font-bold mb-4">#{label}</p>)
    html << %(<h2 class="#{h2_class}">#{title}</h2>)
    html << %(<p class="text-on-surface-variant text-lg font-body">#{subtitle}</p>) if subtitle
    html << '</header>'
    html
  end

  # Inline SVG icons. Replaces the Material Symbols ligature font: the page
  # used four icons, and until the font loaded the browser painted the ligature
  # name ("science", "arrow_forward") as literal text. Decorative by default
  # (aria-hidden), so screen readers skip them and only the label is read.
  LAB_ICON_PATHS = {
    flask: '<path d="M9 2.75h6"/>' \
           '<path d="M10 2.75V9.65L4.6 18.4C3.8 19.7 4.8 21.3 6.3 21.3H17.7' \
           'C19.2 21.3 20.2 19.7 19.4 18.4L14 9.65V2.75"/>' \
           '<path d="M7.6 14.3H16.4"/>',
    arrow_forward: '<path d="M5 12h14"/><path d="m12 5 7 7-7 7"/>',
    person: '<path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>' \
            '<circle cx="12" cy="7" r="4"/>'
  }.freeze

  def lab_icon(name, size: 24, css: nil, stroke_width: 1.8)
    paths = LAB_ICON_PATHS.fetch(name.to_sym)
    %(<svg class="#{css}" width="#{size}" height="#{size}" viewBox="0 0 24 24" fill="none" ) +
      %(stroke="currentColor" stroke-width="#{stroke_width}" stroke-linecap="round" ) +
      %(stroke-linejoin="round" aria-hidden="true" focusable="false">#{paths}</svg>)
  end

  LAB_PUBLIC_DIR = File.expand_path('../../public', __dir__).freeze

  # Cache buster for the /lab assets. They ship with a 3-day Cache-Control and
  # no fingerprint in the filename, so without this a CSS or JS change stays
  # invisible for three days to anyone who visited recently. Two stats per
  # render, which is cheaper than the static-file serving already doing them.
  def lab_asset(path)
    file = File.join(LAB_PUBLIC_DIR, path.delete_prefix('/'))
    return path unless File.exist?(file)

    "#{path}?v=#{File.mtime(file).to_i.to_s(36)}"
  end

  LAB_CONTACT_EMAIL = 'lab@kleer.la'.freeze

  # WhatsApp link, reusing Kleer's number until Lab gets its own.
  # Set LAB_WHATSAPP_NUMBER (digits with country code) to enable the button.
  def lab_whatsapp_link
    number = ENV['LAB_WHATSAPP_NUMBER'].to_s.gsub(/\D/, '')
    return nil if number.empty?

    "https://wa.me/#{number}"
  end
end
