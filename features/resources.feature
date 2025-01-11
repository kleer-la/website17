Feature: Resource Page SEO

  @SEO-validation
  Scenario: Individual resource page in Spanish should have correct meta tags
    Given a resource exists with:
      | slug              | agile-basics     |
      | title            | Agile Básico     |         # Main title for H1
      | tabtitle         | Agile Básico - Completo     |         # For both browser tab and og:title
      | seo_description  | Una guía completa sobre metodologías ágiles |
      | cover            | /img/agile-cover.jpg |
    When I visit "/es/recursos/agile-basics"
    Then SEO meta name "description" should be "Una guía completa sobre metodologías ágiles"
    And SEO meta property "og:title" should be "Agile Básico - Completo" 
    And the page title should be "Agile Básico - Completo"
    And SEO meta property "og:description" should be "Una guía completa sobre metodologías ágiles"
    And SEO meta property "og:image" should be "/img/agile-cover.jpg"
    # And SEO hreflang "es" should have href "/es/recursos/agile-basics"

  @SEO-validation
  Scenario: Individual resource page in English should have correct meta tags
    Given a resource exists with:
      | slug           | agile-basics     |
      | title          | Agile Basics     |
      | tabtitle       | Agile Basics - Complete Guide |
      | seo_description| A complete guide to agile methodologies |
      | cover          | /img/agile-cover.jpg |
    When I visit "/en/recursos/agile-basics"
    Then SEO meta name "description" should be "A complete guide to agile methodologies"
    And SEO meta property "og:title" should be "Agile Basics - Complete Guide"
    And SEO meta property "og:description" should be "A complete guide to agile methodologies"
    And SEO meta property "og:image" should be "/img/agile-cover.jpg"
    # And SEO hreflang "en" should have href "/en/recursos/agile-basics"
    And The page should have one H1 tag
    And the page should not have a noindex meta tag

  @SEO-validation 
  Scenario: Long resource description should be properly truncated in meta tags
    Given a resource exists with:
      | slug           | agile-basics     |
      | title          | Agile Básico     |
      | seo_description| Una guía muy muy muy muy muy muy muy muy muy muy muy muy muy muy muy muy muy muy muy muy muy muy muy muy muy muy muy muy muy muy muy muy muy muy muy muy muy muy muy muy muy muy muy larga sobre metodologías ágiles |
    When I visit "/es/recursos/agile-basics"
    Then SEO meta "name" "description" should match "^.{50,160}$"
    And SEO meta property "og:description" should match "^.{50,160}$"

  Scenario: Resource page should handle non-existent resources
    Given a resource exists with:
      | slug           | agile-basics     |
      | title          | Agile Básico     |
    When I visit "/es/recursos/non-existent-resource"
    Then I should see "Página no encontrada"