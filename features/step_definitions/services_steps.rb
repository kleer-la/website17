require './lib/models/service_area_v3'

Given('I visit a not existing service page') do
  ServiceAreaV3.null_json_api(NullJsonAPI.new(nil, nil), NullJsonAPI.new(nil, nil))
  visit '/servicios/not-exist'
end

Given('a service {string} with slug {string}') do |name, slug|
  service = <<-HEREDOC
  {
    "id": 3,
    "slug": "service-area",
    "slug_old": null,
    "name": "Area",
    "icon": "/app/img/icons/ev-org.svg",
    "summary": "...",
    "cta_message": "...",
    "primary_color": "#4dd3e8",
    "secondary_color": "#34e3ff",
    "slogan": "...",
    "subtitle": "...",
    "description": "...",
    "side_image": "https://kleer-images.s3.sa-east-1.amazonaws.com/dla%20grupo%20lideres%20interactuando.png",
    "target_title": "...",
    "target": "...",
    "value_proposition": "...",
    "value_proposition_title": "...",
    "seo_title": "SEO #{name}",
    "seo_description": "...",
    "services": [
    {
    "id": 6,
    "slug": "#{slug}",
    "slug_old": null,
    "name": "#{name}",
    "subtitle": "...",
    "value_proposition": "...",
    "outcomes": [ "...", "..." ],
    "definitions": null,
    "program": [ ["La Estructura", "Determina el posicionamiento de responsabilidad e identidad en una organización."] ],
    "target": "...",
    "pricing": "",
    "faq": [ ["Primera pregunta", "Respuesta 1ra pregunta"] ],
    "brochure": "",
    "side_image": "https://www.kleer.la/app/img/services/diseno-org.webp",
    "recommended_way_title": "Membresía IA",
    "recommended_way_note": "Funciona para el 80%",
    "recommended_way_summary": "<ol><li>Paso alto nivel</li></ol>",
    "recommended_way_details": "<div id='forma-recomendada'>Detalles completos aquí</div>"
    }
  ]
  }
  HEREDOC
  ServiceAreaV3.null_json_api(NullJsonAPI.new(nil, nil), NullJsonAPI.new(nil, service))
end

Given('a list that includew service area {string} with slug {string}') do |name, slug|
  service_areas = <<-HEREDOC
  [
    {
    "id": 3,
    "slug": "#{slug}",
    "name": "#{name}",
    "icon": "/app/img/icons/ev-org.svg",
    "summary": "...",
    "cta_message": "...",
    "primary_color": "#4dd3e8",
    "secondary_color": "#34e3ff",
    "services": [
    {
    "id": 6,
    "slug": "evolucion-organizacional-agil",
    "name": "Evolución Organizacional Ágil",
    "subtitle": "<div>Diseñando organizaciones adaptativas para el logro de los objetivos estratégicos.</div>"
    },
    {
    "id": 7,
    "slug": "desarrollo-liderazgo-agil",
    "name": "Desarrollo del Liderazgo Ágil",
    "subtitle": "<div>Fortalece las habilidades de los líderes para guiar el cambio organizacional.</div>"
    }
    ],
    "testimonies": []
    }
  ]
  HEREDOC
  ServiceAreaV3.null_json_api(NullJsonAPI.new(nil, service_areas), NullJsonAPI.new(nil, nil))
end

# Forma Recomendada steps (used by @forma-recomendada scenario)
Given('a service {string} with slug {string} and recommended way data') do |name, slug|
  # Delegates to the regular step (which now includes recommended_way fields)
  step "a service \"#{name}\" with slug \"#{slug}\""
end

Then('I should see the recommended way summary block') do
  expect(page).to have_css('.recommended-way')
  expect(page).to have_content('80%')
end

Then('I should see the full recommended way details block with id {string}') do |id|
  expect(page).to have_css("##{id}")
  expect(page.body).to include('Detalles completos')
end
