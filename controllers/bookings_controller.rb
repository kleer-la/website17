require './lib/json_api'
require './lib/services/booking_token'
require './lib/services/mailer'
require './lib/models/service_area_v3'

include Recaptcha::Adapters::ControllerMethods

get %r{/agendar/([^/]+)} do |slug|
  token_payload = params[:token] && BookingToken.valid?(params[:token], area_slug: slug)
  unless token_payload
    status 404
    return
  end

  service_area = ServiceAreaV3.create_keventer(slug)
  return status 404 if service_area.nil?

  consultants = []
  begin
    response = JsonAPI.new(KeventerAPI.service_area_consultants_url(slug))
    if response.ok? && response.doc.is_a?(Array)
      consultants = response.doc
    end
  rescue StandardError
    # Fall back to empty consultants
  end

  @meta_tags.set! title: service_area.name,
                  description: service_area.seo_description

  erb :'bookings/index', layout: :'layout/layout2022', locals: {
    service_area: service_area,
    consultants: consultants,
    booking_token: params[:token],
    visitor_name: token_payload['name'] || '',
    visitor_email: token_payload['email'] || '',
    slug: slug
  }
end

post '/qualify-booking' do
  unless verify_recaptcha
    flash[:error] = t('mailer.error')
    redirect "/#{session[:locale]}#{params[:context]}"
    return
  end

  area_slug = (params[:area_slug] || '').strip
  message = (params[:message] || '').strip
  context = params[:context] || '/'

  # Check if booking qualification is possible
  has_consultants = false
  if !area_slug.empty? && message.length >= 50
    begin
      response = JsonAPI.new(KeventerAPI.service_area_consultants_url(area_slug))
      has_consultants = response.ok? && response.doc.is_a?(Array) && !response.doc.empty?
    rescue StandardError
      # API failure — fall through to mail
    end
  end

  if has_consultants
    token = BookingToken.generate(email: params[:email], area_slug: area_slug, name: params[:name])
    redirect "/#{session[:locale]}/agendar/#{area_slug}?token=#{token}"
  else
    mail_data = {
      name: params[:name],
      email: params[:email],
      company: params[:company],
      message: message,
      context: context,
      language: session[:locale],
      resource_slug: params[:resource_slug] || '',
      initial_slug: params[:resource_slug] || '',
      can_we_contact: true,
      suscribe: false
    }
    send_mail(mail_data)
    flash[:notice] = t('mailer.success')
    redirect "/#{session[:locale]}#{context}"
  end
end

get '/consultant-availability/:id' do
  unless params[:token] && params[:area_slug] && BookingToken.valid?(params[:token], area_slug: params[:area_slug])
    halt 403, { error: 'forbidden' }.to_json
  end

  content_type :json
  begin
    response = JsonAPI.new(
      KeventerAPI.consultant_availability_url(
        params[:id],
        start: params[:start],
        end: params[:end],
        timezone: params[:timezone]
      )
    )
    if response.ok?
      response.doc.to_json
    else
      status 502
      { error: 'upstream_error' }.to_json
    end
  rescue StandardError
    status 502
    { error: 'upstream_error' }.to_json
  end
end

post '/book-meeting' do
  content_type :json

  unless params[:booking_token] && params[:area_slug] && BookingToken.valid?(params[:booking_token], area_slug: params[:area_slug])
    halt 403, { error: 'forbidden' }.to_json
  end

  begin
    url = KeventerAPI.consultant_booking_url(params[:consultant_id])
    response = Faraday.post(url) do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = {
        secret: ENV['CONTACT_US_SECRET'],
        visitor_name: params[:visitor_name],
        visitor_email: params[:visitor_email],
        start: params[:start_time],
        end: params[:end_time],
        service_area_slug: params[:area_slug]
      }.to_json
    end

    if response.status == 200 || response.status == 201
      JSON.parse(response.body).to_json
    else
      status response.status
      { error: 'booking_failed' }.to_json
    end
  rescue StandardError
    status 502
    { error: 'upstream_error' }.to_json
  end
end

post '/send-booking-inquiry' do
  unless params[:booking_token] && params[:area_slug] && BookingToken.valid?(params[:booking_token], area_slug: params[:area_slug])
    halt 403
  end

  mail_data = {
    name: params[:name],
    email: params[:email],
    company: params[:company],
    message: params[:message],
    context: "/agendar/#{params[:area_slug]}",
    language: session[:locale],
    resource_slug: '',
    initial_slug: '',
    can_we_contact: true,
    suscribe: false
  }
  send_mail(mail_data)
  flash[:notice] = t('booking.inquiry_sent')
  redirect "/#{session[:locale]}/agendar/#{params[:area_slug]}"
end
