def get_event_type(event_type_id, find_it: true)
  NullJsonAPI.new(nil, File.read('./spec/catalog.json'))

  # NullInfraestructure json
  EventType.null_json_api(
    NullJsonAPI.new(
      find_it ? "./spec/event_type_#{event_type_id}.json" : nil
    )
  )
end

Given(/^theres an event type$/) do
  get_event_type(4)
end

Given(/^theres an event type with several editions$/) do
  get_event_type(2)
end

When(/^I visit the plain event type page$/) do
  visit '/categoria/productos-robustos/cursos/4-xxx'
end

When('I visit the event type full page') do
  visit '/categoria/productos-robustos/cursos/2-yyy'
end

When(/^I visit a non existing event type page$/) do
  get_event_type(1, find_it: false)
  visit '/categoria/productos-robustos/cursos/1-xxx'
end

Given(/^I visit an event type detail page$/) do
  visit '/categoria/productos-robustos/cursos/4-xxx'
end

Then(/^I should see a rating$/) do
  expect(page).to have_selector('.stars')
end

Then(/^I should not see a rating$/) do
  expect(page).not_to have_selector('.stars')
end

Given(/^there is a event type with subtitle$/) do
  @event_type_id = 1
  get_event_type(@event_type_id)
end

When(/^I visit this event type page$/) do
  visit "/cursos/#{@event_type_id}-xxx"
  # visit "/categoria/productos-robustos/cursos/#{@event_type_id}-xxx"
end

Given(/^there is a event type with duration$/) do
  @event_type_id = 1
end
Given(/^there is a event type with no duration$/) do
  @event_type_id = 3
end

Given('I expect duration to be {string}') do |text|
  expect(page).to have_selector("#duration-#{@event_type_id}", exact_text: text)
end

Given('theres an event type with noindex') do
  get_event_type(4)
end
