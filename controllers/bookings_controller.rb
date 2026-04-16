require './lib/json_api'
require './lib/services/booking_token'
require './lib/services/mailer'
require './lib/models/service_area_v3'

include Recaptcha::Adapters::ControllerMethods

get %r{/agendar/([^/]+)} do |slug|
  service_area = ServiceAreaV3.create_keventer(slug)
  return status 404 if service_area.nil?

  # Fetch consultants for this service area
  consultants = []
  has_consultants = false
  begin
    response = JsonAPI.new(KeventerAPI.service_area_consultants_url(slug))
    if response.ok? && response.doc.is_a?(Array) && !response.doc.empty?
      consultants = response.doc
      has_consultants = true
    end
  rescue StandardError
    # If API fails, fall back to no-consultants mode
  end

  qualified = false
  booking_token = nil
  if has_consultants && params[:token]
    if BookingToken.valid?(params[:token], area_slug: slug)
      qualified = true
      booking_token = params[:token]
    else
      flash[:error] = t('booking.error_expired_token')
    end
  end

  @meta_tags.set! title: service_area.name,
                  description: service_area.seo_description

  erb :'bookings/index', layout: :'layout/layout2022', locals: {
    service_area: service_area,
    consultants: consultants,
    has_consultants: has_consultants,
    qualified: qualified,
    booking_token: booking_token,
    slug: slug
  }
end

post '/qualify-booking' do
  unless verify_recaptcha
    flash[:error] = t('booking.error_recaptcha')
    redirect "/#{session[:locale]}/agendar/#{params[:area_slug]}"
    return
  end

  area_slug = params[:area_slug]
  name = params[:name]
  email = params[:email]
  company = params[:company]
  situation = params[:situation] || ''
  has_consultants = params[:has_consultants] == 'true'

  if has_consultants && situation.length >= 50
    token = BookingToken.generate(email: email, area_slug: area_slug)
    redirect "/#{session[:locale]}/agendar/#{area_slug}?token=#{token}"
  else
    mail_data = {
      name: name,
      email: email,
      company: company,
      message: situation,
      context: "/agendar/#{area_slug}",
      language: session[:locale],
      resource_slug: '',
      initial_slug: '',
      can_we_contact: true,
      suscribe: false
    }
    send_mail(mail_data)
    flash[:notice] = t('booking.inquiry_sent')
    redirect "/#{session[:locale]}/agendar/#{area_slug}"
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
  rescue StandardError => e
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
        start_time: params[:start_time],
        timezone: params[:timezone],
        service_area_id: params[:service_area_id]
      }.to_json
    end

    if response.status == 200 || response.status == 201
      JSON.parse(response.body).to_json
    else
      status response.status
      { error: 'booking_failed' }.to_json
    end
  rescue StandardError => e
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
