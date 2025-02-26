require './lib/models/assessment'
require 'spec_helper'

describe Assessment do
  let(:mock_doc) do
    {
      'id'=>1,
      'title'=>'Test Assessment',
      'description'=>'Test Description',
      'question_groups'=>[
        {
          'id'=>1,
          'name'=>'Domain',
          'position'=>1,
          'questions'=>[
            {
              'id'=>1,
              'text'=>'Grouped Q1',
              'position'=>1,
              'question_type'=>'linear_scale',
              'answers'=>[
                {
                  'id'=>1,
                  'text'=>'Low',
                  'position'=>1
                }
              ]
            }
          ]
        }
      ],
      'questions'=>[
        {
          'id'=>2,
          'text'=>'Standalone Q1',
          'position'=>2,
          'question_type'=>'linear_scale',
          'answers'=>[
            {
              'id'=>2,
              'text'=>'Small',
              'position'=>1
            }
          ]
        }
      ]
    }
  end

  describe '#initialize' do
    it 'initializes basic attributes in English' do
      assessment = Assessment.new(mock_doc, 'en')

      expect(assessment.id).to eq 1
      expect(assessment.title).to eq 'Test Assessment'
      expect(assessment.description).to eq 'Test Description'
    end

    it 'initializes question groups and questions' do
      assessment = Assessment.new(mock_doc, 'en')

      expect(assessment.question_groups.size).to eq 1
      expect(assessment.question_groups.first.name).to eq 'Domain'
      expect(assessment.question_groups.first.questions.size).to eq 1
      expect(assessment.question_groups.first.questions.first.text).to eq 'Grouped Q1'
      expect(assessment.question_groups.first.questions.first.answers.first.text).to eq 'Low'

      expect(assessment.questions.size).to eq 1
      expect(assessment.questions.first.text).to eq 'Standalone Q1'
      expect(assessment.questions.first.answers.first.text).to eq 'Small'
    end
  end

  describe '#question_type' do
    it 'correctly sets question_type for all questions' do
      assessment = Assessment.new(mock_doc, 'en')

      expect(assessment.question_groups.first.questions.first.question_type).to eq 'linear_scale'
      expect(assessment.questions.first.question_type).to eq 'linear_scale'
    end
  end

  describe '.create_one_null' do
    it 'creates a test assessment and enables null testing mode' do
      test_assessment = {
        'id'=>1,
        'title'=>'Mock Assessment',
        'description'=>'Mock Description',
        'question_groups'=>[
          {
            'id'=>1,
            'name'=>'Mock Domain',
            'position'=>1,
            'questions'=>[
              {
                'id'=>1,
                'text'=>'Mock Q1',
                'position'=>1,
                'question_type'=>'linear_scale',
                'answers'=>[
                  {
                    'id'=>1,
                    'text'=>'Mock Low',
                    'position'=>1
                  }
                ]
              }
            ]
          }
        ],
        'questions'=>[
          {
            'id'=>2,
            'text'=>'Mock Standalone',
            'position'=>2,
            'question_type'=>'linear_scale',
            'answers'=>[
              {
                'id'=>2,
                'text'=>'Mock Small',
                'position'=>1
              }
            ]
          }
        ]
      }

      Assessment.create_one_null(test_assessment, 'en', next_null: true)
      assessment = Assessment.create_one_keventer(1)

      expect(assessment.id).to eq 1
      expect(assessment.title).to eq 'Mock Assessment'
      expect(assessment.question_groups.first.name).to eq 'Mock Domain'
      expect(assessment.questions.first.text).to eq 'Mock Standalone'
    end
  end

  describe '.create_one_keventer' do
    it 'raises AssessmentNotFoundError when assessment not found' do
      allow(KeventerAPI).to receive(:assessment_url).and_return('http://example.com/assessments/999')
      allow(JsonAPI).to receive(:new).with('http://example.com/assessments/999').and_raise(AssessmentNotFoundError.new(999))

      expect do
        Assessment.create_one_keventer(999)
      end.to raise_error(AssessmentNotFoundError, "Assessment with ID '999' not found")
    end
  end
end