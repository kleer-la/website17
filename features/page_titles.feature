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
    Given there is resource "Some resource"
		And I visit the "publicamos" page
		Then the page title should includes "^Kleer"
		And the page title should includes "Recursos sobre Agile"

	Scenario: Servicios Title
    Given a service "Chaos control" with slug "chaos-control"
    And I visit the "servicios/chaos-control" page
		Then the page title should includes "^Kleer"
		And the page title should includes "SEO Chaos control"

	Scenario: Somos Title
    Given a kleerer "Pepe Marrone" with LinkedIn "pepe.marrone"
		And I visit the "somos" page
		Then the page title should includes "^Kleer"
		And the page title should includes "Quiénes Somos"
		And the page title should includes "Somos"

