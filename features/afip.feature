Feature: Data Fiscal AFIP (Argentina)

	Scenario: Data Fiscal AFIP
    Given  PENDING: removed from home -> to be moved to Somos?
		Given I visit the home page
		Then I should see the Argentinian fiscal data QR
		Then I should see the Argentinian fiscal data link