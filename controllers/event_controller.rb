# API routes for participant registration - separate from main app to avoid global error handlers

require './controllers/mailer_controller'
require './lib/services/keventer_api'
require './lib/models/participant_registration'

# Participant registration route (new API-based version)
get '/events/:event_id/participants/register' do |event_id|
  # Fetch event data from API with language parameter for proper date formatting
  @lang = session[:locale] || 'es'

  begin
    # Use new ParticipantRegistration model
    participant_registration = ParticipantRegistration.new(event_id)
    event_result = participant_registration.load_event_data(@lang)

    # Handle different response types from the model
    if event_result[:success]
      @event = event_result[:data]
    else
      case event_result[:error]
      when :not_found
        # Send error notification email for event not found
        send_error_notification({
          error_type: 'Event Not Found',
          url: request.url,
          event_id: event_id,
          language: @lang,
          timestamp: Time.now.strftime('%Y-%m-%d %H:%M:%S UTC'),
          error_message: 'Event not found via ParticipantRegistration model',
          additional_details: "Event ID: #{event_id}",
          user_agent: request.user_agent,
          ip: request.ip
        })

        @meta_tags.set! title: t('page_not_found')
        status event_result[:status]
        return erb :'home/error_404', layout: :'layout/layout2022'
      when :service_unavailable
        # API service is unavailable - trigger 503 error handling below
        raise StandardError.new('Service unavailable')
      end
    end

    # Validate that @event has required structure to prevent nil access errors
    if @event.nil? || !@event.is_a?(Hash) || @event['event_type'].nil? || !@event['event_type'].is_a?(Hash)
      # Send error notification email
      send_error_notification({
        error_type: 'Invalid API Response',
        url: request.url,
        event_id: event_id,
        language: @lang,
        timestamp: Time.now.strftime('%Y-%m-%d %H:%M:%S UTC'),
        error_message: 'API returned invalid event data structure',
        additional_details: "Event data: #{@event.inspect}",
        user_agent: request.user_agent,
        ip: request.ip
      })

      @meta_tags.set! title: t('internal_error.title')
      status 503
      return erb :'layout/error_500', layout: :'layout/layout2022'
    end

    # Use scoped locale instead of global
    I18n.with_locale(@lang.to_sym) do
      # Calculate pricing for different quantities (1-6 people)
      @pricing_data = {}
      (1..6).each do |qty|
        pricing_result = participant_registration.load_pricing_data(qty)

        if pricing_result[:success]
          @pricing_data[qty] = pricing_result[:data]
        end
        # If pricing fails, we just don't include it in @pricing_data
        # The view should handle missing pricing gracefully
      end

      erb :'participants/register', layout: false
    end
  rescue StandardError => e
    # Send error notification email for unexpected errors
    send_error_notification({
      error_type: 'Unexpected Exception',
      url: request.url,
      event_id: event_id,
      language: @lang,
      timestamp: Time.now.strftime('%Y-%m-%d %H:%M:%S UTC'),
      error_message: e.message,
      additional_details: "Exception class: #{e.class}, Backtrace: #{e.backtrace.first(5).join('\n')}",
      user_agent: request.user_agent,
      ip: request.ip
    })

    @meta_tags.set! title: t('internal_error.title')
    status 503
    erb :'layout/error_500', layout: :'layout/layout2022'
  end
end

# Handle registration form submission
post '/events/:event_id/participants/register' do |event_id|
  content_type :json
  
  begin
    # Forward the registration to the Rails API
    api_url = "#{ENV['KEVENTER_URL'] || 'https://eventos.kleer.la'}/api/v3/events/#{event_id}/participants/register"
    
    response = HTTParty.post(api_url, {
      body: params.to_h,
      headers: { 'Accept' => 'application/json' }
    })
    
    if response.success?
      response.body
    else
      status response.code
      response.body
    end
  rescue Errno::ECONNREFUSED, Net::TimeoutError, SocketError, HTTParty::Error => e
    # Network/connection errors - service unavailable
    status 503
    { error: "Registration service temporarily unavailable", details: e.message }.to_json
  rescue StandardError => e
    # Other unexpected errors - but try to return JSON instead of triggering global handler
    halt 500, { error: "Registration failed due to unexpected error", details: e.message }.to_json
  end
end

# Confirmation page for new API-based registration
get '/events/:event_id/participant_confirmed' do |event_id|
  @event_id = event_id
  @free = params[:free] == 'true'
  @api = params[:api] == '1'
  @lang = session[:locale] || 'es'
  begin
    event = Event.create_from_api(event_id)
    @event_type_id = event&.event_type_id
  rescue StandardError => e
    # Fallback if Event.create_from_api fails
    @event_type_id = nil
  end
  
  I18n.with_locale(@lang.to_sym) do
    erb :'participants/confirmed', layout: false
  end
end