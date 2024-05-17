Feature:  Páginas de servicios.

  @SEO-validation
  @generic-validations
  Scenario: Página DLA
    Given a service "Chaos control" slug "chaos-control" with
    And   I visit the "servicios/chaos-control" page
    Then I should see "Chaos control"

  Scenario: Servicio no existente
    Given I visit a not existing service page
    Then I should see "Página no encontrada"
