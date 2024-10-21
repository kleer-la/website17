Feature: Testimonial and Blog Routing
  Case studies managed as Articles
  Incremental migration of case studies

  Scenario Outline: Accessing testimonial or blog content
    And A list of articles with
    * an article 'existing-blog' with title 'Lorem ipsum'
    When I go to "<slug>" client page
    Then <action>

    Examples:
      | slug           | action                                        |
      | existing-blog  | Title should be "Lorem ipsum"                 |
      | afp-crecer  | It should redirect to "/es/blog/afp-crecer"      |
      | non-existent   | It should redirect to "/es/blog/non-existent" |
