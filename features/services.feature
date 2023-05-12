Feature:  Páginas de servicios.

  Scenario: Página DLA
    Given  I visit the "servicios/desarrollo-liderazgo-agil" page
    Then I should see "Programa de Desarrollo del Liderazgo Ágil"
    And I should see "Contenido del Programa de Desarrollo del Liderazgo Ágil"

  Scenario: Servicio no existente
    Given I visit the "servicios/no-existe" page
    Then I should see "Página no encontrada"
