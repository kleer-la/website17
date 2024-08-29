When('the host is {string}') do |host|
  page.driver.header 'HOST', host
end

Then('the response should include the header {string} with value {string}') do |header, value|
  expect(page.response_headers[header]).to eq(value)
end

Then('the response should not include the header {string}') do |header|
  expect(page.response_headers[header]).to be_nil
end
