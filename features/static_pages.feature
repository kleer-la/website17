Feature: Static pages - Frequently asked questions
	@generic-validations
	Scenario: Privacy page
		Given I visit the Privacy page
		Then I should see "Declaración de privacidad"

	@generic-validations
	Scenario: Terms page
		Given I visit the Terms page
		Then I should see "Términos de servicio"
