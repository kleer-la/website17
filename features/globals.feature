Feature: Globals

	Scenario: 404 Page
		Given I visit an invalid Page
		Then I should get a 404 error
		And the page title should be "404 - No encontrado"
		And I should see "Página no encontrada"
