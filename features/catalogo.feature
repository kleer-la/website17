Feature: Catalogo de cursos

	Scenario: Mostrar las categorías
		Given I visit the "catalogo" page
		Then I should see "Desarrollo Profesional"
		And I should see "Desarrollo de Software"

	Scenario: Show event type subtitle
		Given I visit the catalog page
		Given PENDING
		Then I should see "Capacitación profesional en Agilidad"

	Scenario: Show event type duration
		Given PENDING
		Given there is a event type with duration
		When I visit the "catalogo" page
		Then I expect duration to be "8 horas"

#	Scenario: Show event type w/o duration
#   		 Given PENDING
#		Given there is a event type with no duration
#		When I visit the "catalogo" page
#		Then I expect duration to be ""
