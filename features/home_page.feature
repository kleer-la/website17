# encoding: utf-8
Feature: Home Page

	Scenario: Tres servicios principales
		Given I visit the home page
		Then I should see "Facilitación"
		And I should see "Agilidad Organizacional"
		And I should see "Cursos"

	Scenario: Datos de contacto
		Given I visit the home page
		Then I should see "Argentina"
		And I should see "Buenos Aires"
		And I should see "Bolivia"
		And I should see "Colombia"
		And I should see "Uruguay"
		And I should see "México"
		And I should see "¿Otro?"

	# Scenario: Integracion con SnapEngage
	# 	Given I visit the home page
	# 	Then I should see the SnapEngage plugin

	Scenario: Subscripcion a newsletter
		Given I visit the home page
		Then I should see "SUSCRÍBETE"
