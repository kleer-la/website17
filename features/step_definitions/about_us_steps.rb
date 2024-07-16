require './lib/trainer'

Given('a kleerer {string} with LinkedIn {string}') do |name, linked_in|
  trainers = <<-HEREDOC
      [{
        "id": 68,
        "name": "#{name}",
        "created_at": "2018-03-20T17:26:36.043Z",
        "updated_at": "2022-09-12T12:34:26.740Z",
        "bio": "Disfruto acompañando ...",
        "gravatar_email": "agustina.leudesdorf@kleer.la",
        "twitter_username": "@AgusLeudesdorf",
        "linkedin_url": "https://www.linkedin.com/in/#{linked_in}",
        "is_kleerer": true,
        "country_id": 9,
        "tag_name": "TR - Agustina Leudesdorf",
        "signature_image": "Agus.png",
        "signature_credentials": "Agile Coach & Trainer",
        "average_rating": "4.76",
        "net_promoter_score": 70,
        "surveyed_count": 137,
        "promoter_count": 32,
        "bio_en": "*Agile coach and trainer.*",
        "deleted": false,
        "landing": null
        }
      ]
  HEREDOC
  Trainer.null_json_api(NullJsonAPI.new(nil, trainers))
end

Then('I should see a LinkedIn for {string}') do |linked_in|
  expect(page).to have_selector("a[href='https://www.linkedin.com/in/#{linked_in}']")
end
