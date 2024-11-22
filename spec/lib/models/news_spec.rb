require 'spec_helper'
require './lib/models/news'
require 'date'

RSpec.describe News do
  describe '.parse' do
    context 'with valid event date' do
      let(:valid_data) do
        {
          'event_date' => '2024-03-15',
          'title' => 'Test Event',
          'description' => 'Test Description'
        }
      end

      it 'parses date correctly' do
        news = News.new(valid_data)
        expect(news.event_date).to eq('15-03-2024')
      end
    end

    context 'with nil event date' do
      let(:nil_date_data) do
        {
          'event_date' => nil,
          'title' => 'Test Event',
          'description' => 'Test Description'
        }
      end

      it 'handles nil date gracefully' do
        news = News.new(nil_date_data)
        expect(news.event_date).to eq('')
      end
    end

    context 'with empty event date' do
      let(:empty_date_data) do
        {
          'event_date' => '',
          'title' => 'Test Event',
          'description' => 'Test Description'
        }
      end

      it 'handles empty date gracefully' do
        news = News.new(empty_date_data)
        expect(news.event_date).to eq('')
      end
    end

    context 'with invalid event date format' do
      let(:invalid_date_data) do
        {
          'event_date' => 'not-a-date',
          'title' => 'Test Event',
          'description' => 'Test Description'
        }
      end

      it 'handles invalid date gracefully' do
        news = News.new(invalid_date_data)
        expect(news.event_date).to eq('')
      end
    end
  end
end
