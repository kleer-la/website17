Feature: In-Company Quote Button and Modal
  As a potential client
  I want to request an in-company quote
  So that I can bring training to my organization

  Scenario: Quote button is always visible on course landing page
    Given An event type
    When I visit the "/es/cursos/1-test-course" page
    Then I should see "Cotiza In-Company"

  Scenario: Quote button opens modal when clicked
    Given An event type
    When I visit the "/es/cursos/1-test-course" page
    And I click on the incompany quote button
    Then I should see the incompany quote modal

  Scenario: Quote modal contains all required fields
    Given An event type
    When I visit the "/es/cursos/1-test-course" page
    And I click on the incompany quote button
    Then I should see the field "Lugar" with options "Online" and "Presencial"
    And I should see the field "¿Cuándo?"
    And I should see the field "Cantidad de asistentes"
    And I should see the field "Tu nombre completo"
    And I should see the field "Correo electrónico"

  Scenario: Where field appears when Presencial is selected
    Given An event type
    When I visit the "/es/cursos/1-test-course" page
    And I click on the incompany quote button
    Then the "Dónde" field should be hidden
    When I select "Presencial" location
    Then the "Dónde" field should be visible

  Scenario: Minimum attendees validation
    Given An event type
    When I visit the "/es/cursos/1-test-course" page
    And I click on the incompany quote button
    Then the "Cantidad de asistentes" field should have minimum value of 8

  Scenario: Quote button visible in English version
    Given An event type in English
    When I visit the "/en/courses/1-test-course" page
    Then I should see "Get In-Company Quote"
