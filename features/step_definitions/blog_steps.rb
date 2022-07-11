Given('A list of articles with') do
  @articles = []
end
Given('an article {string} with title {string}') do |slug, title|
  @articles << { 'slug' => slug, 'title' => title, 'published' => false, 'lang' => @lang }
end
Given('the article has author {string}') do |author|
  @articles[-1]['trainers'] = (@articles[-1]['trainers'] || []) << { 'name' => author }
end

Given('the article has abstract {string}') do |abstract|
  @articles[-1]['abstract'] = abstract
end

When('I go to the {string} article preview page') do |slug|
  Article.create_one_null(@articles[0], { next_null: true, only_published: false })
  visit "/blog-preview/#{slug}"
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
