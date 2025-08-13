Given(/^theres only one event$/) do
  stub_connector
end

Then(/^the registration link has "(.*?)"$/) do |text|
  last_response.body.should have_selector('a.btn.btn-success') do |element|
    element.to_html.should =~ /#{text}/m
  end
end

When(/^I visit the "(.*?)" plain event page$/) do |loc|
  visit "/#{loc}/cursos/13-/remote"
end

When(/^I visit the "(.*?)" event page$/) do |loc|
  visit "/#{loc}/cursos/13-"
end

When(/^I visit the event page$/) do
  visit '/cursos/13-workshop-de-retrospectivas'
end
