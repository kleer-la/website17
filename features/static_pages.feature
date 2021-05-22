Feature: Static pages - Frequently asked questions

Scenario: Privacy page
	Given I visit the Privacy page
	Then I should see "Declaración de privacidad"

Scenario: Terms page
	Given I visit the Terms page
	Then I should see "Términos de servicio"
