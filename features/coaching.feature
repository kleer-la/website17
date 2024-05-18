Feature: Coaching

	@generic-validations
	Scenario: Coaching Text
    Given a list that includew service area "Chaos control" with slug "chaos-control"
		And   I visit the "agilidad-organizacional" page
		Then I should see "Transforma tu Empresa con Agilidad Organizacional"
		And   I should see "Explora Nuestros Servicios de Agilidad Organizacional"
