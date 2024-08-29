Feature: Header & domains
  I want to set the X-Robots-Tag header for qa2 environment
  So that search engines don't index the qa2 site

  Scenario: Accessing qa2 environment
    Given the host is "qa2.kleer.la"
    When I open the web app
    Then the response should include the header "X-Robots-Tag" with value "noindex, nofollow"

  Scenario: Accessing production environment
    Given the host is "www.kleer.la"
    When I open the web app
    Then the response should not include the header "X-Robots-Tag"
    