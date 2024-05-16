Feature: Somos Page

	@generic-validations
	Scenario: Somos
		Given a kleerer "Pepe Marrone" with LinkedIn "pepe.marrone"
    And   I visit the "somos" page
		Then  I should see "Somos"
		And   I should see a LinkedIn for "pepe.marrone"

