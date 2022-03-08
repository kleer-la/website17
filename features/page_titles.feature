Feature: StaticPage Titles

	Scenario: Home Page Title
		Given I visit the home page
		Then the page title should includes "^Kleer"
		And the page title should includes "Agile Coaching, Consulting & Training"
	
	Scenario: Entrenamos Title
		Given I visit the "entrenamos" page
		Then the page title should includes "^Kleer"
		And the page title should includes "Agenda de cursos online sobre Agilidad y Scrum"
		
	Scenario: Entrenamos Title
		Given I visit the "publicamos" page
		Then the page title should includes "^Kleer"
		And the page title should includes "Agile Coaching, Consulting & Training"
	
	Scenario: Coaching Title
		Given I visit the "agilidad-organizacional" page
		Then the page title should includes "^Kleer"
		And the page title should includes "Te acompañamos hacia la agilidad organizacional"
		
	Scenario: Somos Title
		Given I visit the "somos" page
		Then the page title should includes "^Kleer"
		And the page title should includes "Agile Coaching, Consulting & Training"
		And the page title should includes "Somos"
			
	Scenario: Landing de Categoria
		Given I visit the "high-performance" categoria page
		Then the page title should includes "^Kleer"
		And the page title includes "Kleer" just once
		And the page title should includes "Agile Coaching, Consulting & Training"
		And the page title should includes "High Performance"