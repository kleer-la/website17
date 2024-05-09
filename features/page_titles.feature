Feature: StaticPage Titles

	Scenario: Home Page Title
		Given I visit the home page
		Then the page title should includes "^Kleer"
		And the page title should includes "Agile Coaching, Consulting & Training"

	Scenario: Agenda Title
		Given I visit the "agenda" page
		Then the page title should includes "^Kleer"
		And the page title should includes "Agenda de Cursos sobre Métodos Ágiles"

	Scenario: Publicamos Title
		Given I visit the "publicamos" page
		Then the page title should includes "^Kleer"
		And the page title should includes "Recursos sobre Agile"

	Scenario: Servicios Title
		Given I visit the "agilidad-organizacional" page
		Then the page title should includes "^Kleer"
		And the page title should includes "Servicios de Agilidad Organizacional"

	Scenario: Somos Title
		Given I visit the "somos" page
		Then the page title should includes "^Kleer"
		And the page title should includes "Quiénes Somos"
		And the page title should includes "Somos"

