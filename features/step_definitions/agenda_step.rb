When(/^I visit the "(.*?)" agenda page$/) do |page_url|
  visit "/#{page_url}"
end

Given('A list of events') do
  Event.null_json_api(NullJsonAPI.new('./spec/events.json'))
end

# Given('A list of events with') do
#   @events = []
# end

# Given('an event with id {int} name {string} and place {string}') do |id, name, place|
#   @events << { 'id' => id, 'name' => name, 'place' => place, 'lang' => @lang || 'es', 'date' => Date.today }
# end

Then('event {int} should includes {string} as its place') do |event_type_id, place|
  element = find("#place-#{event_type_id}")
  expect(element).to have_text(place)
end

Then('event {int} should have a custom register link {string}') do |event_type_id, link|
  element = find("#buy-#{event_type_id}")
  expect(element[:href]).to eq link
end

Then('event {int} should have a {string} currency') do |event_type_id, currency|
  # File.open('output.html', 'w') {|file| file.write(page.html)}
  element = find("#currency-#{event_type_id}")
  expect(element.text).to include currency
end
