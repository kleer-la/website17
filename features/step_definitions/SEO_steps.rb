#  <meta name="description" content="Acelera el diseño, la creación y la mejora continua...">
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
  expect(all('h1').length == 1)
end

Then('The page should have at least two H2 tags') do
  expect(all('h2').length >= 2)
end
