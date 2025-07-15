Feature: Home Page

	@generic-validations
	Scenario: Two main services
		Given I visit the home page
		And I should see "Agilidad Organizacional"
		And I should see "Cursos"

	Scenario: Subscripcion a newsletter
		Given I visit the home page
		Then I should see "Suscríbete"

	Scenario: Home
		Given I visit the home page
		Then I should see "Agilidad Organizacional"

	Scenario: SEO description
		Given I visit the home page
		Then SEO meta name "description" should be "Descubre el poder de la Transformación Ágil. Contamos con más de 13 años de experiencia acompañando a empresas en su evolución organizacional"
		Then SEO meta property "og:description" should be "Descubre el poder de la Transformación Ágil. Contamos con más de 13 años de experiencia acompañando a empresas en su evolución organizacional"

	Scenario: No noindex
		Given I visit the home page
    Then the page should not have a noindex meta tag

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

	Scenario: Banner section displays when page has banner data
		Given I visit the home page with banner data
		Then I should see the banner section
		And I should see "Special Announcement" in the banner
		And I should see "Join our upcoming webinar series" in the banner
		And I should see "Register Now" in the banner

	Scenario: Banner section does not display when page has no banner data
		Given I visit the home page without banner data
		Then I should not see the banner section

	Scenario: Banner section does not display when banner title is empty
		Given I visit the home page with empty banner title
		Then I should not see the banner section
