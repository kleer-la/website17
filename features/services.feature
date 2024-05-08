Feature:  Páginas de servicios.

  @SEO-validation
  @generic-validations
  Scenario: Página DLA
#    Given a service slug "desarrollo-liderazgo-agil" with
    And   I visit the "servicios/desarrollo-liderazgo-agil" page
    Then I should see "Desarrollo del Liderazgo Ágil"
#    And I should see "Contenido del Programa de Desarrollo del Liderazgo Ágil"

  Scenario: Servicio no existente
    Given I visit the "servicios/no-existe" page
    Then I should see "Página no encontrada"
