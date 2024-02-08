#encoding: utf-8

Feature: Event Type Details

	@generic-validations
	Scenario: Detalle de Evento
		Given A updated event type
		When I visit the plain event type page
		Then the page title should be "Curso actualizado"
		And I should see "Curso actualizado descripcion"

	Scenario: Detalle de Evento con fecha programada
		Given A updated event type
		When I visit the event type full page
		Then the page title should be "Curso actualizado"
		And I should see "06"

	Scenario: Detalle de Evento Inexistente
		Given PENDING
		When I visit a non existing event type page
		Then I should see "no fue encontrado"

	Scenario: Detalle muestra subtitulo
		Given there is a event type with subtitle
		When I visit this event type page
		Then I should see "Subtítulo con más información"

	Scenario: SEO description
	  Given theres an event type
	  When I visit the plain event type page
	  Then SEO meta name "description" should be "Este taller práctico de un día provee a los asistentes..."
	  Then SEO meta property "og:description" should be "Este taller práctico de un día provee a los asistentes..."

	Scenario: Event type detail Title
		Given theres an event type
		When I visit the plain event type page
		Then the page title should includes "^Kleer"
		And the page title includes "Kleer" just once

	Scenario: SEO H-tags structure
		Given theres an event type
		When I visit the plain event type page
		Then The page should have one H1 tag
		And The page should have at least two H2 tags

	Scenario: SEO H-tags structure
		Given theres an event type with noindex
		When I visit the plain event type page
	  Then SEO meta name "robots" should be "noindex"
		