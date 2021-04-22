Feature: Backward Compatibility for 404 URIs

	Scenario: Introducción a Scrum (/entrenamos/introduccion-a-scrum)
		Given I visit the former Introducción a Scrum Page
		Then I should get a 404 error
		
		
	Scenario: Yoseki Spanish (/es/comunidad/yoseki)
		Given I visit the former Yoseki spanish Page
		Then I should get a 404 error
