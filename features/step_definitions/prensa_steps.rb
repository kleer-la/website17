Given(/^I visit the case "(.*?)"$/) do |case_name|
  visit "/prensa/casos/#{case_name}"
end
