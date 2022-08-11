Feature: Kleer Blogs

Scenario: Blog page
  Given I go to the Blog page
  Then Title should be "Reflexiones y pensamientos agiles"

Scenario: unpublished Article dont shown at list page
  Given A list of articles with
  * an article 'lorem-ipsum' with title 'Lorem ipsum'
  When I go to the article list page
  Then I should not see "Lorem ipsum"
