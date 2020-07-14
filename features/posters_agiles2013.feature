
Feature: Posters Agiles 2013

  Scenario Outline: Posters
	Given I visit <poster_page>
	Then I should see <poster_video>
#	And I should see <poster_image>
	And I should see <poster_pdf_download>
	

	Examples:
		|poster_page|poster_video|poster_image|poster_pdf_download|
		| "/posters/scrum" | "IWUG29VPhUA" | "Scrum.jpg" | "https://kleer-images.s3-sa-east-1.amazonaws.com/posters/Scrum.pdf" |
		| "/posters/manifesto" | "V5LaKpjcgKQ" | "Manifesto.jpg" | "https://kleer-images.s3-sa-east-1.amazonaws.com/posters/Manifesto.pdf" |
		| "/posters/xp" | "4nN6Gh79Yg8" | "XP.jpg" | "https://kleer-images.s3-sa-east-1.amazonaws.com/posters/XP.pdf" |