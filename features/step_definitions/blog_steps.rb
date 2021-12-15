Given('A list of articles with') do 
  @articles = []
end
Given('an article {string} with title {string}') do |slug, title|
  @articles << {'slug' => slug, 'title' => title }
end
  
When('I go to the {string} article page') do |slug|
  Article.createOneNull(@articles[0], {next_null: true})
  visit "/blog-preview/#{slug}"
end

Then('Title should be {string}') do |title|
  expect(find('h1')).to have_text title
end
