Feature: Somos Page

	Scenario: Somos
		Given I visit the "somos" page
		Then I should see "Somos"
		And I should see "hola@kleer.la"
		And I should see a linkedin link for a Kleerer with LinkedIn
