Feature: Home Page

	Scenario: Two main services
		Given I visit the home page
		And I should see "Agilidad Organizacional"
		And I should see "Cursos"

	Scenario: Subscripcion a newsletter
		Given I visit the home page
		Then I should see "Suscríbete"

  Scenario: Home 2022
    Given I visit the home page
    Then I should see "Agilidad Organizacional"

	Scenario: SEO description
		Given I visit the home page
		Then SEO meta name "description" should be "Acompañamos hacia la agilidad organizacional. Ofrecemos capacitaciones y cocreamos estrategias de adopción de formas ágiles de trabajo orientadas a objetivos."
		Then SEO meta property "og:description" should be "Acompañamos hacia la agilidad organizacional. Ofrecemos capacitaciones y cocreamos estrategias de adopción de formas ágiles de trabajo orientadas a objetivos."


	Scenario: SEO hreflang
		Given I visit the home page
		Then SEO hreflang "es" should have href "https://www.kleer.la/es/"
		Then SEO hreflang "en" should have href "https://www.kleer.la/en/"

  Scenario: Redirect
    Scenario Outline: Locale
    When I visit the <initial_url> page
    Then It should redirect to <redirect_url>
    Examples:
      |initial_url|redirect_url|
      # | "" | "/es/"|
		