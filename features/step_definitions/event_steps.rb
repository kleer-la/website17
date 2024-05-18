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

When(/^I visit the event page with tracking$/) do
  visit '/cursos/13-workshop-de-retrospectivas?utm_source=cucumber&utm_campaign=feature_test'
end

Then(/^I should see a registration link with tracking$/) do
  response_body.should have_selector("a[href='https://eventos.kleer.la/events/44/participants/new?lang=es&utm_source=cucumber&utm_campaign=feature_test']")
end
