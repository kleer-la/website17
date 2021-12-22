Feature: Catalogo de cursos

	Scenario: Mostrar las categorías
		Given I visit the "catalogo" page
		Then I should see "High Performance"

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
