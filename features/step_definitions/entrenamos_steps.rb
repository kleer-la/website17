require './lib/keventer_reader'

Given('A list of categories') do
  Category.null_json_api( NullJsonAPI.new('./spec/events.json') )
end

Given('A catalog') do
  Catalog.null_json_api( NullJsonAPI.new('./spec/catalog.json') )
end

Given('A deleted event type') do
  EventType.null_json_api( NullJsonAPI.new('./spec/mocks/deleted_event_type.json') )
end

Given('A deleted and redirected event type') do
  EventType.null_json_api( NullJsonAPI.new('./spec/mocks/redirected_event_type.json') )
end

Given('A updated event type') do
  EventType.null_json_api( NullJsonAPI.new('./spec/mocks/updated_event_type.json') )
end

Then(/^event list is empty$/) do
  pending # express the regexp above with the code you wish you had
  last_response.body.should have_selector('a.btn.btn-success') do |element|
    element.to_html.should =~ /#{text}/m
  end
end

Then('It should redirect to {string}') do |path|
  expect(page).to have_current_path(path)
end
