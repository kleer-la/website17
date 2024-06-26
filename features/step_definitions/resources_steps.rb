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
    "landing_es": "https://kleer.la/blog/okrs-para-mejorar-colaboracion-y-foco-en-objetivos-organizacionales",
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
  Resource.create_list_null( NullJsonAPI.new(nil, resources).doc )
end
