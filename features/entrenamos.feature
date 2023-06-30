
Feature: Entrenamos
	Scenario: Deprecated URL should redirect
		Given I visit the "/es/entrenamos/evento/1953-taller-de-product-discovery-online" page
		Then It should redirect to "/es/catalogo"

	Scenario: Deprecated URL should show a msg
		Given PENDING
		Given I visit the "/es/entrenamos/evento/1953-taller-de-product-discovery-online" page
		And I should see "no fue encontrado"

	Scenario: SEO meta tags in Agenda
		Given PENDING
		Given I visit the "/es/agenda" page
#		Then SEO hreflang "es" should have href "https://www.kleer.la/es/"
#		And SEO hreflang "en" should have href "https://www.kleer.la/en/"
		Then the page title should includes "Kleer"
		And SEO meta name "description" should be "Capacitaciones sobre Facilitación, Lean, Kanban, Product Discovery,Agile Coaching, Retrospectivas, Liderazgo, Mejora continua, Gestión del tiempo y más."
		And SEO meta name "og:description" should be "Capacitaciones sobre Facilitación, Lean, Kanban, Product Discovery,Agile Coaching, Retrospectivas, Liderazgo, Mejora continua, Gestión del tiempo y más."

