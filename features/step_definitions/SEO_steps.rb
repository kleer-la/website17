#  <meta name="description" content="Acelera el diseño, la creación y la mejora continua...">
After('@SEO-validation') do |_scenario|
  expect(all('h1').length).to eq(1)
  expect(page.html).not_to match(/\/es\/es/)
  expect(page.html).not_to match(/\/es\/en/)
  expect(page.html).not_to match(/\/en\/es/)
  expect(page.html).not_to match(/\/en\/en/)

  expect(page).to have_css('link[rel="canonical"]', visible: false), 'Canonical link is missing'
end

Then('SEO meta name {string} should be {string}') do |tag, text|
  expect(page).to have_tag('meta',
                           with: {
                             name: tag,
                             content: text
                           })
end

Then('SEO meta property {string} should be {string}') do |tag, text|
  expect(page).to have_tag('meta',
                           with: {
                             property: tag,
                             content: text
                           })
end

Then('The page should have one H1 tag') do
   expect(all('h1').length). to eq(1)
end

Then('The page should have at least two H2 tags') do
  expect(all('h2').length >= 2)
end

Then('SEO hreflang {string} should have href {string}') do |lang, url|
  expect(page.html).to match /<link.*hreflang=\"#{lang}\" href=\"#{url}\"/
end

Then('SEO meta {string} {string} should match {string}') do |tag, tag_name, pattern|
  meta_tags = page.all('meta', visible: false)  # Find all meta tags

  found = false
  meta_tags.each do |meta_tag|
    if meta_tag[tag.to_sym] == tag_name
      found = true
      expect(meta_tag[:content]).to match Regexp.new(pattern)
      break
    end
  end
  (expect(tag+tag_name).to eq pattern ) unless found
end
