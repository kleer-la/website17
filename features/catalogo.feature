# encoding: utf-8
Feature: Catalogo de cursos

	Scenario: Mostrar las categorías
		Given I visit the "catalogo" page
		Then I should see "High Performance"

#   Scenario: Mostrar ratings
#       Given feature "show_rates_on_catalog" is on
#       When I visit the "catalogo" page
#       Then I should see a rating

  Scenario: No mostrar ratings
      Given feature "show_rates_on_catalog" is off
      When I visit the "catalogo" page
      Then I should not see a rating

	Scenario: Show event type subtitle
		Given I visit the "catalogo" page
		Then I should see "Taller de TDD"
		And I should see "Some Subtitle"

	Scenario: Show event type duration
		Given there is a event type with duration
		When I visit the "catalogo" page
		Then I expect duration to be "8 horas"

	Scenario: Show event type w/o duration
		Given there is a event type with no duration
		When I visit the "catalogo" page
		Then I expect duration to be ""
