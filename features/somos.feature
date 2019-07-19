Feature: Somos Page

	Scenario: Somos
		Given I visit the "somos" page
		Then I should see "Somos"
		And I should see "Martín Alaimo"
		And I should see "@martinalaimo"
		And I should see a linkedin link for a Kleerer with LinkedIn
