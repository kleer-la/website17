Feature: Legacy routes

  Scenario: Old Acompañamos page
    Given I have data from Keventer API
    And I navigate to "acompanamos"
    Then It should redirect to "/es/servicios"