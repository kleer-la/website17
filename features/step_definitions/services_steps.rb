require './lib/models/service_area_v3'

Given('I visit a not existing service page') do
  ServiceAreaV3.null_json_api( NullJsonAPI.new(nil, nil) )
  visit '/servicios/not-exist'
end

Given('a service {string} slug {string} with') do |name, slug|
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
    "seo_title": "...",
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
    "side_image": "https://www.kleer.la/app/img/services/diseno-org.jpg"
    }
  ]
  }
  HEREDOC
  ServiceAreaV3.null_json_api( NullJsonAPI.new(nil, service ) )
end

  