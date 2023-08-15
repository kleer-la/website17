When(/^I visit the "(.*?)" agenda page$/) do |page_url|
  visit "/#{page_url}"
end

Given('A list of events') do
  Event.null_json_api( NullJsonAPI.new('./spec/events.json') )
end

# Given('A list of events with') do
#   @events = []
# end

# Given('an event with id {int} name {string} and place {string}') do |id, name, place|
#   @events << { 'id' => id, 'name' => name, 'place' => place, 'lang' => @lang || 'es', 'date' => Date.today }
# end

Then('event {int} should includes {string} as its place') do |event_id, place|
  # File.open('output.html', 'w') {|file| file.write(page.html)}
  element = find("#place-#{event_id}")
  expect(element).to have_text(place)
end