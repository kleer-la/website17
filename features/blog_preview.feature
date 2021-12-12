Feature: Blog preview

Scenario: Blog previe page
  Given I have 'lorem-ipsum' article
  When I go to the 'lorem-ipsum' article page
  Then Title should be "Lorem Ipsum"

