
Feature: Agenda (fka Entrenamos)
	Scenario: Deprecated URL should redirect
		Given I visit the "/es/entrenamos/evento/1953-taller-de-product-discovery-online" page
		Then It should redirect to "/es/catalogo"

	Scenario: Deprecated URL should show a msg
		Given PENDING
		Given I visit the "/es/entrenamos/evento/1953-taller-de-product-discovery-online" page
		And I should see "no fue encontrado"

	Scenario: SEO meta tags in Agenda
		Given I visit the "/es/agenda" page
#		Then SEO hreflang "es" should have href "https://www.kleer.la/es/"
#		And SEO hreflang "en" should have href "https://www.kleer.la/en/"
		Then the page title should includes "Kleer"
		And SEO meta "property" "og:description" should match "Capacitaciones"
		And SEO meta "name" "description" should match "Capacitaciones en"

	Scenario: Online Event 
    Given A list of events
		Given I visit the "/es/agenda" agenda page
		Then event 72 should includes "Online" as its place

	Scenario: in-person event
    Given A list of events
		Given I visit the "/es/agenda" agenda page
		Then event 7 should includes "CABA" as its place

