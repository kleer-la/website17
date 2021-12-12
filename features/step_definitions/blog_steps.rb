Given('I have {string} article') do |slug|
end

When('I go to the {string} article page') do |slug|
    visit "/blog-preview/#{slug}"
end

Then('Title should be {string}') do |title|
    expect( find("h1") ).to have_text title
end