
Feature: Posters Agiles 2013

  Scenario Outline: Posters
	When I visit the <poster_page> page
	Then I should redirect to "/recursos"
	Examples:
		|poster_page|not_used|
		| "posters/scrum" | "/recursos#scrum"|
		| "posters/manifesto" | "/recursos#manifesto"|
		| "posters/xp" | "/recursos#XP"|
		| "posters/XP" | "/recursos#XP"|
		