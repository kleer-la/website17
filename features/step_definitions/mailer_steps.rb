Given('I send a POST request to {string}') do |url|
  page.driver.post(url)
end

Then('the response status should be {int}') do |status_code|
  expect(page.status_code).to eq(status_code)
end
