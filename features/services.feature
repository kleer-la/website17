Feature:  Páginas de servicios.

  @SEO-validation
  @generic-validations
  Scenario: Página DLA
    Given a service "Chaos control" with slug "chaos-control"
    And   I visit the "servicios/chaos-control" page
    Then I should see "Chaos control" 
  Scenario: Servicio no existente
    Given I visit a not existing service page
    Then I should see "Página no encontrada"

  @forma-recomendada
  Scenario: Servicio con Forma Recomendada muestra Summary y Details
    Given a service "Adopción IA" with slug "adopcion-ia-empresas" and recommended way data
    And   I visit the "servicios/cambio-organizacional/adopcion-ia-empresas" page
    Then  I should see the recommended way summary block
    And   I should see the full recommended way details block with id "forma-recomendada"
