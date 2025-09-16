# API routes for participant registration - separate from main app to avoid global error handlers

# Participant registration route (new API-based version)
get '/events/:event_id/participants/register' do |event_id|
  # Fetch event data from API with language parameter for proper date formatting
  @lang = session[:locale] || 'es'
  api_url = "#{ENV['KEVENTER_URL'] || 'https://eventos.kleer.la'}/api/events/#{event_id}?lang=#{@lang}"
  response = HTTParty.get(api_url, headers: { 'Accept' => 'application/json' })
  
  if response.success?
    @event = response.parsed_response
    
    # Use scoped locale instead of global
    I18n.with_locale(@lang.to_sym) do
      # Calculate pricing for different quantities (1-6 people)
      @pricing_data = {}
      (1..6).each do |qty|
        pricing_url = "#{ENV['KEVENTER_URL'] || 'https://eventos.kleer.la'}/api/v3/events/#{event_id}/participants/pricing_info?quantity=#{qty}"
        pricing_response = HTTParty.get(pricing_url, headers: { 'Accept' => 'application/json' })
        if pricing_response.success?
          @pricing_data[qty] = pricing_response.parsed_response
        end
      end
      
      erb :'participants/register', layout: false
    end
  else
    status 404
    "Event not found"
  end
rescue StandardError => e
  status 503
  "Service temporarily unavailable: #{e.message}"
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