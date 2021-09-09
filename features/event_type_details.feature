#encoding: utf-8

Feature: Event Type Details

	Scenario: Detalle de Evento
		Given theres an event type
		When I visit the plain event type page
		Then the page title should be "Introducción a Scrum (Módulo 1 - CSD Track)"
		And I should see " principios fundamentales de las metodologías ágiles y de Scrum"
		And I should see "Este taller práctico de un día provee a los asistentes"

	Scenario: Detalle de Evento con varias fechas programadas
		Given theres an event type with several editions
		When I visit the event type full page
		Then the page title should be "Taller Popular de Scrum"
		And I should see "01"
		And I should see "05"

	Scenario: Detalle de Evento Inexistente
		When I visit a non existing event type page
		Then I should see "Curso no encontrado"

	Scenario: Detalle muestra subtitulo
		Given there is a event type with subtitle
		When I visit this event type page
		Then I should see "Subtítulo con más información"

	Scenario: SEO description
		Given there is a event type with description "SEO description"
		When I visit this event type page
		Then SEO meta "description" should be "" 
		#"SEO description"
