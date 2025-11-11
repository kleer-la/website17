Feature: In-Company Quote Button and Modal
  As a potential client
  I want to request an in-company quote
  So that I can bring training to my organization

  Scenario: Quote button is always visible on course landing page
    Given An event type
    When I visit the "/es/cursos/1-test-course" page
    Then I should see "Cotiza In-Company"

  Scenario: Quote modal exists on page
    Given An event type
    When I visit the "/es/cursos/1-test-course" page
    Then I should see the incompany quote modal exists on page

  Scenario: Quote modal contains all required fields
    Given An event type
    When I visit the "/es/cursos/1-test-course" page
    Then I should see the field "Lugar" with options "Online" and "Presencial"
    And I should see the field "¿Cuándo?"
    And I should see the field "Cantidad de asistentes"
    And I should see the field "Tu nombre completo"
    And I should see the field "Correo electrónico"

  Scenario: Where field is initially hidden
    Given An event type
    When I visit the "/es/cursos/1-test-course" page
    Then the "Dónde" field should be initially hidden

  Scenario: Minimum attendees validation
    Given An event type
    When I visit the "/es/cursos/1-test-course" page
    Then the "Cantidad de asistentes" field should have minimum value of 8

  Scenario: Quote button visible in English version
    Given PENDING: English routing needs proper test fixture setup
    Given An event type in English
    When I visit the "/en/courses/1-test-course" page
    Then I should see "Get In-Company Quote"
