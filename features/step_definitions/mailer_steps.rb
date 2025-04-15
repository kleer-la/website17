Given('I send a POST request to {string}') do |url|
  page.driver.post(url)
end
