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

  LAB_CONTACT_EMAIL = 'lab@kleer.la'.freeze

  # WhatsApp link, reusing Kleer's number until Lab gets its own.
  # Set LAB_WHATSAPP_NUMBER (digits with country code) to enable the button.
  def lab_whatsapp_link
    number = ENV['LAB_WHATSAPP_NUMBER'].to_s.gsub(/\D/, '')
    return nil if number.empty?

    "https://wa.me/#{number}"
  end
end
