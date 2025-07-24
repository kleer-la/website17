require './lib/models/contact'

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
    @contact = Contact.new(contact_data || {})
    return erb :'resources/assessment/results', layout: :'layout/layout2022'
  end

  email_data = contact_data.merge(
    assessment_id: assessment_id,
    assessment_results: responses
  )

    begin
      mailer = Mailer.new(KeventerAPI.contacts_url, email_data)
      
      # Check for API errors
      if mailer.parsed_body&.key?('error')
        error_message = mailer.parsed_body['error']
        puts "API Error: #{error_message}" if ENV['RACK_ENV'] == 'development'
        @error_message = case error_message
                        when 'bad secret'
                          'Configuration error. Please contact support.'
                        when /validation/i
                          'Invalid submission data. Please check your responses and try again.'
                        else
                          'Assessment submission failed. Please try again later.'
                        end
        @contact = Contact.new(contact_data)
        return erb :'resources/assessment/results', layout: :'layout/layout2022'
      end

      @id = mailer.id
      @status = mailer.status
      @assessment_report_url = mailer.assessment_report_url
      
      # Validate required fields
      unless @id
        if ENV['RACK_ENV'] == 'development'
          puts "Missing contact ID in API response: #{mailer.parsed_body}"
        end
        @error_message = 'Assessment submission failed. Please try again later.'
        @contact = Contact.new(contact_data)
        return erb :'resources/assessment/results', layout: :'layout/layout2022'
      end
      
      if ENV['RACK_ENV'] == 'development'
        puts "Assessment submitted successfully - Contact ID: #{@id}, Status: #{@status}"
      end
      
    rescue StandardError => e
      if ENV['RACK_ENV'] == 'development'
        puts "Assessment submission error: #{e.message}"
        puts "Error backtrace: #{e.backtrace&.first(5)}"
      end
      @error_message = 'Assessment submission failed due to a technical error. Please try again later.'
      @contact = Contact.new(contact_data)
      return erb :'resources/assessment/results', layout: :'layout/layout2022'
    end

    # Clear session data after successful submission
    session[:contact_data] = nil
    contact_data[:id] = @id
    contact_data[:status] = @status
    contact_data[:assessment_report_url] = @assessment_report_url
    contact_data = contact_data.transform_keys(&:to_s)
    
    @contact = Contact.new(contact_data)
    
    @success_message = 'Respuestas enviadas correctamente, revisa tu correo para los resultados.'
    erb :'resources/assessment/results', layout: :'layout/layout2022'
end

get '/assessment/:contact_id/result_status' do
  response = JsonAPI.new(KeventerAPI.contact_status_url(params[:contact_id]))
  content_type :json
  response.instance_variable_get(:@doc).to_json
end

get '/assessment/:contact_id/result' do
  @contact = Contact.create_one_keventer(params[:contact_id])
  @assessment = @contact.assessment
  erb :'resources/assessment/results', layout: :'layout/layout2022'
end