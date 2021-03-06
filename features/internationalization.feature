Feature: i18n

	Scenario: Default menu in Spanish
		Given I visit the home page
		Then I should see "Facilitación"
		And I should see "Coaching"
		And I should see "Cursos"

	Scenario: Spanish menu
		Given I visit the spanish home page
		Then I should see "Facilitación"
		And I should see "Coaching"
		And I should see "Cursos"

	Scenario: English menu
		Given I visit the english home page
		Then I should see "Facilitation"
		And I should see "Coaching"
		And I should see "Courses"

	Scenario: English entrenamos
		Given I visit the english "entrenamos"
		Then I should see "All"

	Scenario: Default menu in Spanish; then select "English"
		Given I visit the home page
		When I switch to "ENGLISH"
		Then I should see "Facilitation"
		And I should see "Coaching"
		And I should see "Courses"

	Scenario: English menu; then select "Español"
		Given I visit the english home page
		When I switch to "ESPAÑOL"
		Then I should see "Facilitación"
		And I should see "Coaching"
		And I should see "Cursos"

