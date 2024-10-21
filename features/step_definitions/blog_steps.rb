Given('A list of articles with') do
  @articles = []
end
Given('an article {string} with title {string}') do |slug, title|
  @articles << { 'slug' => slug, 'title' => title, 'published' => false, 'lang' => @lang || 'es' }
end
Given('the article has author {string}') do |author|
  @articles[-1]['trainers'] = (@articles[-1]['trainers'] || []) << { 'name' => author }
end

Given('the article has description {string}') do |description|
  @articles[-1]['description'] = description
end

Given('the article has language {string}') do |lang|
  @articles[-1]['lang'] = lang
end

When('I go to {string} client page') do |slug|
  Article.create_one_null(@articles[0], { next_null: true })
  visit "/clientes/testimonios/#{slug}"
end

When('I go to the {string} article preview page') do |slug|
  Article.create_one_null(@articles[0], { next_null: true, only_published: false })
  visit "/blog-preview/#{slug}"
end
When('I go to the {string} article page') do |slug|
  Article.create_one_null(@articles[0], { next_null: true })
  visit "/blog/#{slug}"
end

When('I go to the article list page') do
  Article.create_list_null(@articles, { next_null: true, only_published: true })
  visit '/blog'
end
When('I go to the article list preview page') do
  Article.create_list_null(@articles, { next_null: true, only_published: false })
  visit "/#{@lang || 'es'}/blog-preview"
end

Then('Title should be {string}') do |title|
  expect(all('h1').first).to have_text title
end

Given('With {string} locale') do |lang|
  @lang = lang
end

Given(/^I go to the Blog page$/) do
  Article.create_list_null([], { next_null: true, only_published: false })
  visit '/es/blog'
end
