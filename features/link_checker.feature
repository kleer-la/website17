@system
Feature: Link Checker
  In order to ensure all links on the website are working
  As a website maintainer
  I want to check for any broken links

Scenario: Check website for broken
  Given the site is crawled
  Then I should see no broken links
  And Save the crawling results

  Scenario: Check website for double lang prefix
  Given the site is crawled
  Then No URL with double '/es' prefix
  And No URL with double '/en' prefix

  Scenario: Validate external URLs
  Given the site is crawled
  Then all external URLs should be valid
