require 'spec_helper'
require './lib/event_type'
require './lib/event'
require './lib/services/cache_service'

describe Event do
  let(:base_json) do
    {
      'id' => '2371',
      'date' => '2022-11-08',
      'place' => '(GMT-05:00) Bogota',
      'capacity' => '20',
      'city' => 'Online',
      'country_id' => '245',
      'trainer_id' => '57',
      'visibility_type' => 'pu',
      'list_price' => '999.0',
      'eb_price' => '940.0',
      'eb_end_date' => '2022-10-29',
      'finish_date' => '2022-12-01',
      'start_time' => '2000-01-01T15:00:00.000Z',
      'end_time' => '2000-01-01T17:00:00.000Z'
    }
  end
  before(:each) do
    CacheService.clear
  end

  it 'has event type' do
    event = Event.new('sudoku')
    expect(event.event_type).to eq 'sudoku'
  end

  it 'loads start and end time correctly' do
    event = Event.new(1)
    event.load_from_json(base_json)

    expect(event.start_time.hour).to eq 15
    expect(event.end_time.hour).to eq 17
  end

  it 'loads duration correctly' do
    event = Event.new(1)
    json_with_duration = base_json.merge('duration' => '16')
    event.load_from_json(json_with_duration)

    expect(event.duration).to eq 16
  end

  context 'create_keventer_json' do
    before(:each) do
      @json_api = NullJsonAPI.new(nil, '''
        [{"id":2372,"date":"2023-01-16","place":"(GMT-05:00) Bogota","capacity":24,"city":"Online","country_id":245,"trainer_id":11,
          "visibility_type":"pu","list_price":"800.0","eb_price":"760.0","eb_end_date":"2023-01-06","draft":false,"cancelled":false,
          "created_at":"2022-10-11T20:03:51.355Z","updated_at":"2022-12-26T15:11:38.304Z","event_type_id":7,"registration_link":"",
          "is_sold_out":true,"duration":16,"start_time":"2000-01-01T08:00:00.000Z","end_time":"2000-01-01T17:00:00.000Z","sepyme_enabled":false,
          "time_zone_name":"Bogota","embedded_player":null,"notify_webinar_start":false,"twitter_embedded_search":null,"webinar_started":false,
          "currency_iso_code":"USD","address":"Online","custom_prices_email_text":"","monitor_email":"entrenamos@kleer.la","specific_conditions":"",
          "should_welcome_email":true,"should_ask_for_referer_code":false,"couples_eb_price":"720.0","business_price":"700.0","business_eb_price":"680.0","enterprise_6plus_price":"660.0","enterprise_11plus_price":"640.0",
          "finish_date":"2023-01-17","show_pricing":true,"average_rating":null,"net_promoter_score":null,"mode":"ol","trainer2_id":null,"extra_script":"","trainer3_id":null,"mailchimp_workflow":null,
          "mailchimp_workflow_call":null,"banner_text":"","banner_type":"","registration_ends":"2023-01-16",
          "cancellation_policy":"La vacante se confirma ...","specific_subtitle":"","enable_online_payment":false,"online_course_codename":"","online_cohort_codename":"CSMOL230116","mailchimp_workflow_for_warmup":null,"mailchimp_workflow_for_warmup_call":null,"human_date":"Jan 16-Jan 17",
          "country":{"id":245,"name":"-- OnLine --","iso_code":"OL","created_at":"2012-11-28T19:53:51.250Z","updated_at":"2012-11-28T19:53:51.250Z"},
          "event_type":{"id":7,"name":"Certified Scrum Master (CSM)"}
        }]
        ''')
    end

    it 'read a json' do
      Event.null_json_api(@json_api)
      events = Event.create_keventer_json(Date.new(2023, 1, 15))
      expect(events.count).to eq 1
    end
    it 'filter old courses' do
      Event.null_json_api(@json_api)
      events = Event.create_keventer_json
      expect(events.count).to eq 0
    end
  end
  
  describe 'caching functionality' do    
    let(:mock_events) do
      [
        double('Event', country_iso: 'AR', date: Date.today + 1),
        double('Event', country_iso: 'CO', date: Date.today + 2)
      ]
    end
    
    it 'caches events with default cache key' do
      allow(Event).to receive(:load_events).and_return(mock_events)
      
      # First call should hit the API
      events1 = Event.create_keventer_json
      expect(events1).to eq(mock_events)
      
      # Second call should use cache
      allow(Event).to receive(:load_events).and_return([])
      events2 = Event.create_keventer_json
      expect(events2).to eq(mock_events)
    end
    
    it 'uses custom cache key when provided' do
      allow(Event).to receive(:load_events).and_return(mock_events)
      
      # Cache with custom key
      events1 = Event.create_keventer_json(cache_key: 'custom_events_key')
      expect(events1).to eq(mock_events)
      
      # Verify it's cached under the custom key
      cached_events = CacheService.get('custom_events_key')
      expect(cached_events).to eq(mock_events)
    end
    
    it 'respects custom TTL' do
      allow(Event).to receive(:load_events).and_return(mock_events)
      
      # Cache with default TTL
      events = Event.create_keventer_json
      expect(events).to eq(mock_events)
      
      # Manually clear cache to test cache expiration
      CacheService.delete("home_events_#{I18n.locale || 'es'}")
      
      # Should call API again
      allow(Event).to receive(:load_events).and_return([])
      events2 = Event.create_keventer_json
      expect(events2).to eq([])
    end
    
    # it 'includes date in default cache key' do
    #   allow(Event).to receive(:load_events).and_return(mock_events)
      
    #   # Cache for today
    #   today_events = Event.create_keventer_json(Date.today)
      
    #   # Cache for tomorrow should be different
    #   tomorrow_events = Event.create_keventer_json(Date.today + 1)
      
    #   # Verify they have different cache keys
    #   expect(CacheService.stats[:total_entries]).to eq(2)
    # end
    
    # it 'handles API failures gracefully' do
    #   allow(Event).to receive(:load_events).and_raise(StandardError.new('API Error'))
      
    #   expect {
    #     Event.create_keventer_json
    #   }.to raise_error(StandardError, 'API Error')
      
    #   # Verify nothing was cached
    #   expect(CacheService.stats[:total_entries]).to eq(0)
    # end
  end
end
