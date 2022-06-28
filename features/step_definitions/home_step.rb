Given('I visit {string} page') do |url|
  stub_connector
  visit "/#{url}"
end