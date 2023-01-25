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
		Then SEO meta name "description" should be "Descubre el poder de la Transformación Ágil. Contamos con la experiencia de más de 10 años acompañando a clientes hacia la agilidad organizacional"
		Then SEO meta property "og:description" should be "Descubre el poder de la Transformación Ágil. Contamos con la experiencia de más de 10 años acompañando a clientes hacia la agilidad organizacional"


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

#	Scenario: Coming courses
#		When I visit the home page
#
