# encoding: utf-8
Feature: Entrenamos
		
	Scenario: Country options in entrenamos page
		Given I visit the entrenamos page
		Then I should see all countries highlited

	Scenario: Próximos eventos (todos)
		Given there are two events
		When I visit the entrenamos ajax page
		Then I should see the json string for all of the events

	Scenario: Codigo de pais de Argentina (ar)
		Given there are two events
		When I visit the entrenamos ajax page for Argentina
		Then I should see the json string for the Argentina events

	Scenario: Codigo de pais erroneo
		Given there are two events
		When I visit the entrenamos ajax page for an invalid country
		Then I should see the json string for all of the events

	Scenario: Codigo de pais otros
		Given there are two events
		When I visit the entrenamos ajax page for other country
		Then I should see the json string with no events

#	Scenario: Mas eventos, filtrados para Bolivia
#		Given there are many events
#		When I visit the entrenamos ajax page for Bolivia
#		Then I should see the json string for the Bolivia events
