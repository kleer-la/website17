Feature: English URL Validation
  As a customer
  I want to ensure that all English pages use proper English URLs
  So that there are no mixed language URLs like /en/recursos or /es/resources

  Background: Keventer
    Given I have data from Keventer API

  Scenario Outline: English menu pages should use English URLs
    When I visit "/en<english_url>"
    Then the page should load successfully
    And the page should be in English
    And the URL should not contain Spanish terms
    And the content should not contain Spanish terms

    Examples:
      | english_url                                    |
      | /                                              |
      | /services                                      |
      | /services/organizational-change-and-leadership |
      | /services/product-management                   |
      | /services/team-agility                         |
      | /catalog                                       |
      # | /schedule                                      |
      | /clients                                       |
      | /resources                                     |
      | /blog                                          |
      | /about_us                                      |
      | /certificate                                   |

# Scenario Outline: Mixed language URLs should not exist
#   When I attempt to visit "<mixed_url>"
#   Then the page should either redirect or return a 404 error

#   Examples:
#     | mixed_url       |
#     | /en/recursos    |
#     | /en/servicios   |
#     | /en/catalogo    |
#     | /en/agenda      |
#     | /en/clientes    |
#     | /en/somos       |
#     | /en/certificado |
#     | /es/resources   |
#     | /es/services    |
#     | /es/catalog     |
#     | /es/schedule    |
#     | /es/clients     |
#     | /es/about_us    |
#     | /es/certificate |

# Scenario: English resource page should use /en/resources/ pattern
#   Given a resource exists with:
#     | slug            | scrum-guide                       |
#     | title           | Scrum Guide                       |
#     | tabtitle        | The Scrum Guide                   |
#     | seo_description | Complete guide to Scrum framework |
#     | cover           | /img/scrum.jpg                    |
#   When I visit "/en/resources/scrum-guide"
#   Then the page should load successfully
#   And the page should be in English
#   And the URL should contain "/en/resources/"
#   And the URL should not contain "recursos"

# Scenario: English event type page should use /en/cursos/ pattern
#   Given an event type exists with:
#     | id   | 123                    |
#     | name | Certified Scrum Master |
#     | slug | certified-scrum-master |
#     | lang | en                     |
#   When I visit "/en/cursos/123-certified-scrum-master"
#   Then the page should load successfully
#   And the page should be in English
#   And the URL should contain "/en/cursos/"

# Scenario Outline: Spanish pages should use Spanish URLs correctly
#   When I visit "/es<spanish_url>"
#   Then the page should load successfully
#   And the page should be in Spanish
#   And the URL should not contain English terms

#   Examples:
#     | spanish_url  |
#     | /            |
#     | /servicios   |
#     | /catalogo    |
#     | /agenda      |
#     | /clientes    |
#     | /recursos    |
#     | /blog        |
#     | /somos       |
#     | /certificado |

# Scenario: Navbar links should use correct language-specific URLs
#   Given I visit "/en/"
#   When I examine the navigation menu
#   Then all menu links should use English URLs
#   And no menu link should contain Spanish terms like "recursos", "servicios", "catalogo"

# Scenario: Footer links should use correct language-specific URLs
#   Given I visit "/en/"
#   When I examine the footer menu
#   Then all footer links should use English URLs
#   And no footer link should contain Spanish terms like "recursos", "servicios", "catalogo"

# Scenario: Language switcher should work correctly
#   Given I visit "/en/resources"
#   When I click the language switcher to "ESPAÑOL"
#   Then I should be redirected to "/es/recursos"
#   And the page should be in Spanish

# Scenario: Language switcher should work correctly (reverse)
#   Given I visit "/es/recursos"
#   When I click the language switcher to "ENGLISH"
#   Then I should be redirected to "/en/resources"
#   And the page should be in English

# Scenario: Search engine should not index mixed language URLs
#   When a search engine attempts to access "/en/recursos"
#   Then the response should redirect, return 404, or have noindex directive

# @link-validation
# Scenario: All links on English pages should use English URLs
#   Given I visit "/en/"
#   When I extract all internal links from the page
#   Then no internal link should contain Spanish URL segments
#   And all links with /en/ prefix should use English terms
#   And no link should match the pattern "/en/(recursos|servicios|catalogo|agenda|clientes|somos|certificado)"