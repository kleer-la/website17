# encoding: utf-8

Feature: Categories

	Scenario: Category Landing Page
		Given I visit the "high-performance" categoria page
		Then I should see "High Performance"
		And I should see "Personas, Equipos y Organizaciones Eficientes"

	Scenario: Category not found
		Given I visit the "unknown" categoria page
		Then I should get a 404 error
		And the page title should be "404 - No encontrado"
		And I should see "404 - No encontrado"

	Scenario: Event type list in Category Landing Page
		Given I visit the "high-performance" categoria page
		Then I should see "Tipo de Evento de Prueba"

	Scenario: Event type details Page
		Given theres an event type
		When I visit an event type detail page
		Then I should see "Kleer"
