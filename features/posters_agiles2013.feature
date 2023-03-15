
Feature: Posters Agiles 2013

  Scenario Outline: Posters
	When I visit the <poster_page> page
	Then It should redirect to <redirected>
	Examples:
		|poster_page|redirected|
		| "posters/scrum" | "/es/recursos"|
		| "posters/manifesto" | "/es/recursos"|
		| "posters/xp" | "/es/recursos"|
		| "posters/XP" | "/es/recursos"|
		