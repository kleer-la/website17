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
        'title' => 'https://example.com/webinar',
        'content' => '{"text":"Join our upcoming webinar series","image":"banner-image.webp","background_color":"#d17e1f"}',
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
        'content' => '{"text":"Some content","image":"banner.webp","background_color":"#d17e1f"}',
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
