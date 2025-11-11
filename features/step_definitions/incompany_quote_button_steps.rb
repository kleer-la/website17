# Step definitions for In-Company Quote Button and Modal feature

Given('An event type') do
  EventType.null_json_api(NullJsonAPI.new('./spec/event_type_1.json'))
end

Given('An event type in English') do
  # Use existing event_type_1.json but override the lang to 'en'
  require 'json'
  event_type_data = JSON.parse(File.read('./spec/event_type_1.json'))
  event_type_data['lang'] = 'en'
  event_type_data['id'] = 1

  EventType.null_json_api(NullJsonAPI.new(nil, event_type_data.to_json))
end

When('I click on the incompany quote button') do
  # Find and click the incompany quote button using data-bs-target attribute
  # This avoids ambiguity when there are multiple buttons with the same text
  find('a[data-bs-target="#incompany-quote-modal"]', match: :first).click
end

Then('I should see the incompany quote modal') do
  # Check if modal is visible - Bootstrap adds 'show' class when modal is open
  expect(page).to have_css('#incompany-quote-modal.show', visible: true)
end

Then('I should see the incompany quote modal exists on page') do
  # Check if modal exists in the DOM (even if not visible)
  expect(page).to have_css('#incompany-quote-modal', visible: :all)
end

Then('I should see the field {string}') do |field_label|
  # Check if the field label is present in the page
  expect(page).to have_content(field_label)
end

Then('I should see the field {string} with options {string} and {string}') do |field_label, option1, option2|
  # Check if the field label exists
  expect(page).to have_content(field_label)

  # Check if both options are present
  expect(page).to have_content(option1)
  expect(page).to have_content(option2)
end

Then('the {string} field should be hidden') do |field_label|
  # The "where-field" div has display:none when hidden
  field_div = page.find('#where-field', visible: :all)
  expect(field_div).not_to be_visible
end

Then('the {string} field should be visible') do |field_label|
  # The "where-field" div becomes visible when Presencial is selected
  field_div = page.find('#where-field', visible: :visible)
  expect(field_div).to be_visible
end

Then('the {string} field should be initially hidden') do |field_label|
  # Check that the where-field has display:none style
  field_div = page.find('#where-field', visible: :all)
  expect(field_div[:style]).to include('display: none')
end

When('I select {string} location') do |location|
  # Select the location option (Online or Presencial) using radio buttons
  case location
  when 'Online'
    find('#location-online').click
  when 'Presencial'
    find('#location-onsite').click
  else
    # Fallback: try to find by label text
    choose(location)
  end
end

Then('the {string} field should have minimum value of {int}') do |field_label, min_value|
  # For "Cantidad de asistentes" field, check the min attribute
  input = page.find('#incompany-attendees-input')
  expect(input[:min].to_i).to eq(min_value)
end
