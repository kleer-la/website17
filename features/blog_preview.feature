Feature: Blog preview

Scenario: Blog previe page
  Given A list of articles with
  * an article 'lorem-ipsum' with title 'Lorem ipsum'
  When I go to the 'lorem-ipsum' article page
  Then Title should be "Lorem ipsum"


