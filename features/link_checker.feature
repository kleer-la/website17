@system
Feature: Link Checker
  In order to ensure all links on the website are working
  As a website maintainer
  I want to check for any broken links

Scenario: Check all links on the website
  # Given the website is running
  When I check all the links
  Then I should see no broken links