Feature: Blog preview

Scenario: One article preview page
  Given A list of articles with
  * an article 'lorem-ipsum' with title 'Lorem ipsum'
  When I go to the 'lorem-ipsum' article preview page
  Then Title should be "Lorem ipsum"

Scenario: One article preview page
  Given A list of articles with
  * an article 'lorem-ipsum' with title 'Lorem ipsum'
  And the article has author 'Luke Skywalker'
  When I go to the 'lorem-ipsum' article preview page
  Then I should see "Luke Skywalker"

Scenario: Article list preview page
  Given A list of articles with
  * an article 'lorem-ipsum' with title 'Lorem ipsum'
  * an article 'dolor-sit-amet' with title 'Dolor sit amet'
  When I go to the article list preview page
  Then I should see "Lorem ipsum"
  And I should see "Dolor sit amet"

Scenario: Article list shows abstract
  Given A list of articles with
  * an article 'lorem-ipsum' with title 'Lorem ipsum'
  And  the article has abstract 'abstract lorem'
  When I go to the article list preview page
  Then I should see "abstract lorem"
