require './lib/models/consultant'
require './lib/services/booking_service'

get %r{/(agendar|schedule)/([a-z0-9_\-]+)} do |_path, area_slug|
  unless feature_on?('booking')
    status 404
    return
  end

  @area = ServiceAreaV3.create_keventer(area_slug)
  return status 404 if @area.nil?

  @consultants = Consultant.for_service_area(area_slug, session[:locale])

  @meta_tags.set! title: t('booking.page_title'),
                  description: t('booking.meta_description'),
                  canonical: "/agendar/#{area_slug}"

  @path = 'agendar'
  set_area_colors(@area)

  erb :'bookings/index', layout: :'layout/layout2022', locals: { area: @area, consultants: @consultants }
end

get '/consultant-availability/:id' do
  unless feature_on?('booking')
    status 404
    return
  end

  content_type :json

  consultant_id = params[:id]
  start_date = params[:start]
  end_date = params[:end]
  timezone = params[:timezone]

  unless start_date && end_date
    status 400
    return { error: 'start and end parameters are required' }.to_json
  end

  availability = Consultant.availability(consultant_id, start_date, end_date, timezone)

  if availability
    availability.to_json
  else
    status 502
    { error: 'Could not fetch availability' }.to_json
  end
end

post '/book-meeting' do
  unless feature_on?('booking')
    status 404
    return
  end

  unless verify_recaptcha
    flash[:error] = t('booking.error')
    redirect "/#{session[:locale]}/agendar/#{params[:area_slug]}"
    return
  end

  data = {
    visitor_name: params[:name],
    visitor_email: params[:email],
    visitor_company: params[:company],
    starts_at: params[:starts_at],
    ends_at: params[:ends_at],
    service_area_slug: params[:area_slug],
    notes: params[:notes],
    language: session[:locale]
  }

  booking = BookingService.new(params[:consultant_id], data)

  if booking.success?
    flash[:notice] = t('booking.success')
    flash[:booking] = {
      consultant_name: booking.consultant_name,
      starts_at: booking.starts_at,
      ends_at: booking.ends_at,
      google_meet_link: booking.google_meet_link
    }
  else
    flash[:error] = t('booking.error')
  end

  redirect "/#{session[:locale]}/agendar/#{params[:area_slug]}"
end
