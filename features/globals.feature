Feature: Globals

	Scenario: 404 Page
		Given I visit an invalid Page
		Then I should get a 404 error
		And the page title should be "Página no encontrada"
		And I should see "Página no encontrada"
