Feature: Coaching

  @generic-validations
  Scenario: Coaching Text
    Given a list that includew service area "Chaos control" with slug "chaos-control"
    And   I visit the "services" page
    Then I should see "Transforma tu Empresa con"
    And   I should see "Agilidad Organizacional"
