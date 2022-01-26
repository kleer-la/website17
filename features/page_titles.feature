Feature: Page Titles

	Scenario: Home Page Title
		Given I visit the home page
		Then the page title should be "Kleer - Agile Coaching, Consulting & Training"
	
	Scenario: Entrenamos Title
		Given I visit the "entrenamos" page
		Then the page title should be "Kleer - Agile Coaching, Consulting & Training | Entrenamos"
		
	Scenario: Entrenamos Title
		Given I visit the "publicamos" page
		Then the page title should be "Kleer - Agile Coaching, Consulting & Training | Publicamos"
	
	Scenario: Coaching Title
		Given I visit the "agilidad-organizacional" page
		Then the page title should be "Kleer - Agile Coaching, Consulting & Training | Coaching"	
		
	Scenario: Somos Title
		Given I visit the "somos" page
		Then the page title should be "Kleer - Agile Coaching, Consulting & Training | Somos"
			
	Scenario: Landing de Categoria
		Given I visit the "high-performance" categoria page
		Then the page title should be "Kleer - Agile Coaching, Consulting & Training | High Performance"