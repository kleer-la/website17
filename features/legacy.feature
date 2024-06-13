Feature: Legacy routes

Scenario: Old Acompañamos page
  Given I navigate to "acompanamos"
	Then It should redirect to "/es/servicios"