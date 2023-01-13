require './lib/keventer_reader'

Then(/^event list is empty$/) do
  pending # express the regexp above with the code you wish you had
  last_response.body.should have_selector('a.btn.btn-success') do |element|
    element.to_html.should =~ /#{text}/m
  end
end

Then('It should redirect to {string}') do |path|
  expect(page).to have_current_path(path)
end
