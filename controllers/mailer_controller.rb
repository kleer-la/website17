require './lib/json_api'
require './lib/services/mailer'

include Recaptcha::Adapters::ControllerMethods

def send_mail(data)
  url = data[:resource_slug] && !data[:resource_slug].empty? ? KeventerAPI.contacts_url : KeventerAPI.mailer_url
  # return JSON.parse(@response) unless @response.nil? # NullInfra -esque
  Mailer.new(url, data)
end

post '/send-mail' do
  unless verify_recaptcha
    flash[:error] = 'Ha ocurrido un error, su mensaje no fué enviado'
    redirect "/#{session[:locale]}#{params[:context]}"
    return
  end

  # Create base data structure first
  base_data = {
    name: params[:name],
    email: params[:email],
    company: params[:company],
    message: params[:message],
    context: params[:context],
    language: session[:locale],
    resource_slug: params[:resource_slug],
    initial_slug: params[:resource_slug],
    can_we_contact: params[:can_we_contact] == 'on',
    suscribe: params[:suscribe] == 'on'
  }
  send_mail(base_data)

  # Send additional resource emails
  additional_resources = params.select { |k, v| k.start_with?('ad-') && v == 'on' }
  additional_resources.each do |key, _|
    resource_slug = key.sub('ad-', '')
    send_mail(base_data.merge(resource_slug: resource_slug))
  end

  flash[:notice] = 'Su mensaje ha sido enviado correctamente'
  redirect "/#{session[:locale]}#{params[:context]}"
end

get '/mailer-template' do
  headers 'X-Robots-Tag' => 'noindex'
  erb :'component/_form_contact', layout: false
end


post '/assessment/:id' do |id|
  unless verify_recaptcha
    flash[:error] = 'Ha ocurrido un error, por favor intenta de nuevo'
    redirect "/#{session[:locale] || 'es'}/recursos/#{params[:resource_slug]}"
    return
  end

  contact_data = {
    name: params[:name],
    email: params[:email],
    company: params[:company],
    context: params[:context],
    language: session[:locale] || 'es',
    resource_slug: params[:resource_slug],
    can_we_contact: params[:can_we_contact] == 'on',
    suscribe: params[:suscribe] == 'on'
  }

  session[:contact_data] = contact_data

  @assessment = Assessment.create_one_keventer(id, session[:locale])
  
  @meta_tags.set! title: @assessment.title,
                  description: @assessment.description,
                  image: "https://kleer-images.s3.sa-east-1.amazonaws.com/website-assets/kleer-logo.png"

  erb :'resources/assessment/show', layout: :'layout/layout2022'
end

post '/submit_assessment' do
  responses = params[:responses]
  assessment_id = params[:assessment_id]
  @assessment = Assessment.create_one_keventer(assessment_id, session[:locale])

  # Retrieve contact data from session
  contact_data = session[:contact_data]
  
  unless contact_data
    status 400
    @error_message = 'No se encontraron datos de contacto'
    return erb :'resources/assessment/results', layout: :'layout/layout2022'
  end

  email_data = contact_data.merge(
    assessment_id: assessment_id,
    assessment_results: responses
  )

    begin
      mailer = Mailer.new(KeventerAPI.contacts_url, email_data)
      @id = mailer.id
      @status = mailer.status
      @assessment_report_url = mailer.assessment_report_url
    rescue StandardError => e
      puts "Failed to send assessment results email: #{e.message}"
    end

    # Clear session data after successful submission
    session[:contact_data] = nil
    @success_message = 'Respuestas enviadas correctamente, revisa tu correo para los resultados.'
    erb :'resources/assessment/results', layout: :'layout/layout2022'
  # rescue StandardError => e
  #   status 500
  #   @error_message = e.message
  #   erb :'resources/assessment/results', layout: :'layout/layout2022'
  # end
end

get '/assessment/:contact_id/result_status' do
  response = JsonAPI.new(KeventerAPI.contact_status_url(params[:contact_id]))
  content_type :json
  puts response.doc
  response.instance_variable_get(:@doc).to_json
end