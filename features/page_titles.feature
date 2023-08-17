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
		And the page title should includes "Agile Coaching, Consulting & Training"

	Scenario: Coaching Title
		Given I visit the "agilidad-organizacional" page
		Then the page title should includes "^Kleer"
		And the page title should includes "Libera el Potencial de la Agilidad Organizacional"

	Scenario: Somos Title
		Given I visit the "somos" page
		Then the page title should includes "^Kleer"
		And the page title should includes "Quiénes Somos"
		And the page title should includes "Somos"

	Scenario: Landing de Categoria
		Given I visit the "high-performance" categoria page
		Then the page title should includes "^Kleer"
		And the page title includes "Kleer" just once
		And the page title should includes "High Performance"
