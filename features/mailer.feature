Feature: External tries to send a mail with the endpoint '/send-mail'

  Scenario: External sends a mail with the endpoint '/send-mail'
    Given I send a POST request to '/send-mail'
    Then the response status should be 403

