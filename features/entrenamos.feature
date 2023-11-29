Feature: Agenda (fka Entrenamos)
	@SEO-validation
	Scenario: Deprecated URL should redirect
		Given A catalog
		Given A list of categories
		And I visit the "/es/entrenamos/evento/1953-taller-de-product-discovery-online" page
		Then It should redirect to "/es/catalogo"

	Scenario: Deprecated URL should show a msg
		Given PENDING
		Given I visit the "/es/entrenamos/evento/1953-taller-de-product-discovery-online" page
		Then I should see "no fue encontrado"

	Scenario: Deleted course should redirect to catalog
		Given A deleted event type
		Given I visit the "/es/cursos/2" page
		Then I should see "Capacitación Empresarial"

	Scenario: Deleted and redirected course should redirect correctly
		Given PENDING
		Given A deleted and redirected event type
		When I visit the "/es/cursos/3" page
#		probar status code 301
		Then I should not see "Curso redireccionado y borrado"

	Scenario: SEO meta tags in Agenda
    	Given A list of events
		Given I visit the "/es/agenda" agenda page
		Then SEO hreflang "es" should have href "https://www.kleer.la/es/agenda"
		And SEO hreflang "en" should have href "https://www.kleer.la/en/agenda"
		Then the page title should includes "Kleer"
		And SEO meta "property" "og:description" should match "Capacitaciones"
		And SEO meta "name" "description" should match "Capacitaciones en"

	Scenario: Online Event
    	Given A list of events
		Given I visit the "/es/agenda" agenda page
		Then event 72 should includes "Online" as its place

	Scenario: in-person event place
    	Given A list of events
		Given I visit the "/es/agenda" agenda page
		Then event 7 should includes "CABA" as its place

	Scenario: event custom registration
    	Given A list of events
		Given I visit the "/es/agenda" agenda page
		Then event 7 should have a custom register link "https://forms.gle/YDsTLArgj2So64EY7"

	Scenario: event currency
    	Given A list of events
		Given I visit the "/es/agenda" agenda page
		Then event 7 should have a "ARS" currency
