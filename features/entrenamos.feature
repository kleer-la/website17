Feature: Entrenamos
		
	# Scenario: Country options in entrenamos page
	# 	Given I visit the "agenda" page
	# 	Then I should see all countries highlited

	Scenario: Deprecated URL
		Given I visit the "/es/entrenamos/evento/1953-taller-de-product-discovery-online" page
		Then I should redirect to "/catalogo"
		And I should see "no fue encontrado"
