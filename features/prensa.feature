Feature: Páginas de prensa.

  @generic-validations
  Scenario: Caso Endava
    Given A list of articles with
    And a published article "capacitaciones-agiles-endava" with title "Endava"
    When I go to "capacitaciones-agiles-endava" client page
    #Given I visit the case "capacitaciones-agiles-endava"
    Then I should see "Endava"

  @generic-validations
  Scenario: Caso EPM
   Given A list of articles with
    And a published article "transformacion-cultural-agil-ti-epm-2018" with title "EPM"
    When I go to "transformacion-cultural-agil-ti-epm-2018" client page
     Then I should see "EPM"

  @generic-validations
  Scenario: Caso BBVA
    Given A list of articles with
    And a published article "transformacion-digital-bbva-continental" with title "Acompañamiento en la transformación digital de BBVA Continental"
    When I go to "transformacion-digital-bbva-continental" client page
    Then I should see "Acompañamiento en la transformación digital de BBVA Continental"
