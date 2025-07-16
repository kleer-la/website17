Given('I visit {string} page') do |url|
  stub_connector
  visit "/#{url}"
end

Given('I visit the home page with banner data') do
  page_data = {
    'lang' => 'es',
    'sections' => [
      {
        'slug' => 'banner',
        'title' => 'Special Announcement',
        'content' => 'Join our upcoming webinar series',
        'cta_text' => 'Register Now'
      }
    ],
    'recommended' => []
  }
  
  Page.api_client = NullJsonAPI.new(nil, page_data.to_json)
  visit '/'
end

Given('I visit the home page without banner data') do
  page_data = {
    'lang' => 'es',
    'sections' => [],
    'recommended' => []
  }
  
  Page.api_client = NullJsonAPI.new(nil, page_data.to_json)
  visit '/'
end

Given('I visit the home page with empty banner title') do
  page_data = {
    'lang' => 'es',
    'sections' => [
      {
        'slug' => 'banner',
        'title' => '',
        'content' => 'Some content',
        'cta_text' => 'Register Now'
      }
    ],
    'recommended' => []
  }
  
  Page.api_client = NullJsonAPI.new(nil, page_data.to_json)
  visit '/'
end

Then('I should see the banner section') do
  expect(page).to have_css('#banner')
end

Then('I should not see the banner section') do
  expect(page).to_not have_css('#banner')
end

Then('I should see {string} in the banner') do |text|
  within('#banner') do
    expect(page).to have_text(text)
  end
end
