Feature: Páginas de prensa.

  @generic-validations
  Scenario: Caso Endava
    Given I visit the case "capacitaciones-agiles-endava"
    Then I should see "Jornada de capacitaciones ágiles en Endava"

  @generic-validations
  Scenario: Caso EPM
    Given I visit the case "transformacion-cultural-agil-ti-epm-2018"
    Then I should see "La Gerencia de TI EPM se transforma culturalmente"

  @generic-validations
  Scenario: Caso BBVA
    Given I visit the case "transformacion-digital-bbva-continental"
    Then I should see "Acompañamiento en la transformación digital de BBVA Continental"
