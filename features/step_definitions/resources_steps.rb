require './lib/models/resources'

Given('there is resource {string}') do |name|
  resources = <<-HEREDOC
  [
    {
      "id": 62,
    "format": "canvas",
    "categories_id": null,
    "trainers_id": null,
    "slug": "okrs-template",
    "landing_es": "https://www.kleer.la/blog/okrs-para-mejorar-colaboracion-y-foco-en-objetivos-organizacionales",
    "cover_es": " https://kleer-images.s3.sa-east-1.amazonaws.com/template-okrs-kleer.png ",
    "title_es": "#{name}",
    "description_es": "...",
    "share_link_es": null,
    "share_text_es": "...",
    "tags_es": "...",
    "comments_es": "...",
    "landing_en": "",
    "cover_en": "",
    "title_en": "",
    "description_en": "",
    "share_link_en": null,
    "share_text_en": "",
    "tags_en": "",
    "comments_en": "",
    "created_at": "2023-12-28T13:58:51.753Z",
    "updated_at": "2023-12-28T14:02:21.661Z",
    "downloadable": null,
    "getit_es": "https://docs.google.com/spreadsheets/u/1/d/1i2C5inSHEHEX6KziRdRImnSzOG_EeFx3C8faGH0jdlI/copy",
    "getit_en": "",
    "buyit_es": "",
    "buyit_en": "",
    "category_name": null,
    "authors": [
    {
    "name": "Pablo Tortorella",
    "landing": "https://twitter.com/pablitux"
    }
    ],
    "translators": [],
    "illustrators": []
    }
  ]
  HEREDOC
  Resource.create_list_null(NullJsonAPI.new(nil, resources).doc)
end

Given('a resource exists with:') do |table|
  resource_data = table.rows_hash

  # Include all required fields to avoid null object issues
  doc = {
    'id' => 1,
    'format' => 'article',
    'slug' => resource_data['slug'],
    'title_es' => resource_data['title'],           # We need to add language suffix
    'tabtitle_es' => resource_data['tabtitle'],     # We need to add language suffix
    'seo_description_es' => resource_data['seo_description'], # We need to add language suffix
    'cover_es' => resource_data['cover'],
    'title_en' => resource_data['title'],           # We need to add language suffix
    'tabtitle_en' => resource_data['tabtitle'],     # We need to add language suffix
    'seo_description_en' => resource_data['seo_description'], # We need to add language suffix
    'cover_en' => resource_data['cover'],
    'authors' => [],
    'translators' => [],
    'illustrators' => [],
    'created_at' => '2024-01-01',
    'updated_at' => '2024-01-01'
  }

  Resource.create_one_null(doc, 'es', next_null: true)
  Resource.create_list_null([doc])
end

Then('SEO meta property {string} should match {string}') do |property, pattern|
  meta_tags = page.all("meta[property='#{property}']", visible: false)
  expect(meta_tags).not_to be_empty
  meta_tags.each do |tag|
    expect(tag[:content]).to match Regexp.new(pattern)
  end
end

Then('I should get a {int} status code') do |code|
  expect(page.status_code).to eq code
end
