require './lib/models/consultant'
require 'spec_helper'

describe Consultant do
  describe '#load_from_json' do
    it 'loads basic attributes' do
      json = {
        'id' => 57,
        'name' => 'Camilo Velasquez',
        'bio' => 'Agile Coach & Trainer',
        'gravatar_email' => 'c.cvelasquez@outlook.com',
        'signature_credentials' => 'Agile Coach & Trainer',
        'linkedin_url' => 'https://linkedin.com/in/camilov'
      }

      consultant = Consultant.new.load_from_json(json)

      expect(consultant.id).to eq 57
      expect(consultant.name).to eq 'Camilo Velasquez'
      expect(consultant.bio).to eq 'Agile Coach & Trainer'
      expect(consultant.gravatar_email).to eq 'c.cvelasquez@outlook.com'
      expect(consultant.role).to eq 'Agile Coach & Trainer'
      expect(consultant.linkedin_url).to eq 'https://linkedin.com/in/camilov'
    end

    it 'uses bio_en for English locale' do
      json = {
        'id' => 1,
        'name' => 'Test',
        'bio' => 'Bio en español',
        'bio_en' => 'Bio in English',
        'gravatar_email' => 'test@test.com',
        'signature_credentials' => 'Coach',
        'linkedin_url' => ''
      }

      consultant = Consultant.new('en').load_from_json(json)
      expect(consultant.bio).to eq 'Bio in English'
    end
  end

  describe '#gravatar_picture_url' do
    it 'returns gravatar URL with email hash' do
      consultant = Consultant.new
      consultant.gravatar_email = 'test@example.com'

      expect(consultant.gravatar_picture_url).to match(%r{https://www\.gravatar\.com/avatar/[a-f0-9]+})
    end

    it 'returns default hash when email is nil' do
      consultant = Consultant.new
      consultant.gravatar_email = nil

      expect(consultant.gravatar_picture_url).to include('default')
    end
  end

  describe '.for_service_area' do
    it 'returns consultants from API' do
      mock_data = [
        { 'id' => 1, 'name' => 'Test Consultant', 'bio' => 'Bio',
          'gravatar_email' => 'test@test.com', 'signature_credentials' => 'Coach',
          'linkedin_url' => '' }
      ]
      Consultant.null_json_api(NullJsonAPI.new(nil, mock_data.to_json))

      consultants = Consultant.for_service_area('agile-coaching')

      expect(consultants.length).to eq 1
      expect(consultants.first.name).to eq 'Test Consultant'
    end

    it 'returns empty array when API fails' do
      Consultant.null_json_api(NullJsonAPI.new(nil))

      consultants = Consultant.for_service_area('nonexistent')

      expect(consultants).to eq []
    end

    after do
      Consultant.api_client = nil
    end
  end
end
