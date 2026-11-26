# Which sections each overlay template reads from its Keventer page, and what
# it does with each (kleer-la/eventer#243).
#
# An overlay is loaded by slug (Page.load_from_keventer(lang, slug), the same
# slug in both languages; the home page has none) and its views read sections
# by slug through Page#section. A section under any other slug is stored in
# Keventer and never shown, so Keventer reads this list from
# /page-templates.json to warn whoever edits a page.
#
# spec/requests/page_templates_spec.rb renders every template and fails when
# what it reads differs from what is declared here, or when a controller loads
# an overlay that is not declared: change this together with the view.
module PageTemplates
  SECTIONS = {
    nil => {
      'hero' => 'Home hero: title is the H1 (one line per row), content the text under it, cta_text the button',
      'banner' => 'Banner under the hero: title, cta_text, and content as a JSON object with ' \
                  'text, image, colours and cta_url',
      'services' => 'Heading (title) and intro (content) of the service areas block',
      'institutional' => 'Institutional block: title (one line per row), content, and cta_text as the URL ' \
                         'of a YouTube embed or an image',
      'clients' => 'Clients block: title, content and cta_text',
      'contact' => 'Closing contact banner: title, content, cta_text and cta_url'
    },
    'novedades' => {
      'hero' => 'Title is the H1 of the news page, content the subtitle under it'
    },
    'agenda' => {
      'agenda' => 'Title of the course schedule (only the title is read)',
      'empty_banner' => 'Shown when no course is scheduled: title and content',
      'empty_academia' => 'Shown when no course is scheduled: the Academia card (title, content, cta_text)',
      'empty_catalog' => 'Shown when no course is scheduled: the catalogue card (title, content, cta_text)'
    },
    'services-landing' => {
      'banner' => 'Top banner of the services page: title, content and cta_text',
      'intro' => 'Intro of the areas block: title, content and cta_text',
      'contact' => 'Closing contact banner: title, content and cta_text'
    },
    'service-area' => {
      'hero' => 'Default hero of every service area and service page (title, content, cta_text), ' \
                'where the area or service has no text of its own',
      'contact' => 'Default closing contact banner of every service area and service page'
    },
    'clientes' => {
      'clients' => 'Clients block: title, content and cta_text'
    },
    # These read only the page's SEO fields and cover.
    'recursos' => {}, 'blog' => {}, 'somos' => {}, 'podcasts' => {}, 'catalogo' => {}, 'llms' => {}
  }.freeze

  # What /page-templates.json answers: a list, since the home page's slug is nil.
  def self.as_json
    { templates: SECTIONS.map { |slug, sections| { slug: slug, sections: sections } } }
  end
end
