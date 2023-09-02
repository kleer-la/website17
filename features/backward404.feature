Feature: Backward Compatibility for 404 and redirection URIs

	Scenario: Introducción a Scrum (/entrenamos/introduccion-a-scrum)
		Given A list of events
		Given I visit the former Introducción a Scrum Page
		Then I should see "Agenda de cursos"
