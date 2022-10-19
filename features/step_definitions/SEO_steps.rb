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
