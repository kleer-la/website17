Given('A list of articles with') do 
  @articles = []
end
Given('an article {string} with title {string}') do |slug, title|
  @articles << {'slug' => slug, 'title' => title, 'published' => false }
end
Given('the article has author {string}') do |author|
  @articles[-1]['trainers'] = (@articles[-1]['trainers']||[]) << {'name' =>author}
end

When('I go to the {string} article preview page') do |slug|
  Article.createOneNull(@articles[0], {next_null: true,only_published: false})
  visit "/blog-preview/#{slug}"
end

When('I go to the article list page') do
  Article.createListNull(@articles, {next_null: true,only_published: true})
  visit "/blog"
end
When('I go to the article list preview page') do
  Article.createListNull(@articles, {next_null: true,only_published: false})
  visit "/blog-preview"
end

Then('Title should be {string}') do |title|
  expect(all('h1').first).to have_text title
end
