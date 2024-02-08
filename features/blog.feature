Feature: Kleer Blogs

  @SEO-validation
  @generic-validations
  Scenario: Blog page
    Given A list of categories
    Given I go to the Blog page
    Then Title should be "Blog"

  @generic-validations
  Scenario: unpublished Article dont shown at list page
    Given A list of categories
    And A list of articles with
    * an article 'lorem-ipsum' with title 'Lorem ipsum'
    When I go to the article list page
    Then I should not see "Lorem ipsum"


# filtering behaviour
# - filter text on titles
# - if filtering, show 'all' (including selected)

#  pagination behavior
# - start as (not 'all') -> showing selected list and blog list w/o selected / item per page = 6 / show 'Show more' button
# - (deleted) next / previous page when (not 'all') ramain in (not 'all')
# - press 'Show more' button -> switch to 'all'
# - 'all' -> show one list including selected / item per page = 9 / don't show 'Show more' button
# - English -> switch to 'all'
