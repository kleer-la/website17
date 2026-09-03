require './lib/models/lab_case'

# Kleer Lab (lab.kleer.la) — served on the `lab.` subdomain, mirroring the
# L'Atelier pattern. Routes are guarded by `@is_lab` (set in app.rb's before
# filter) with `pass unless @is_lab`, so on every other host they fall through
# untouched. `handle_lab_home` / `handle_lab_sitemap` are invoked from the
# shared `/` and `/sitemap.xml` routes; the rest register here, before the
# `/:slug` flagship catch-all in app.rb.

def handle_lab_home
  @lab_title = lab_page_title(:home)
  @lab_description = lab_page_description(:home)
  @cases = LabCase.featured.first(2)
  @home_metrics = LabCase.aggregate_metrics_for_home(limit: 4)
  @featured_testimonials = LabCase.featured_testimonials(limit: 3)
  erb :'lab/home', layout: :'lab/layout'
end

def handle_lab_sitemap
  content_type 'application/xml'
  @lab_base_url = request.base_url
  @cases = LabCase.published
  erb :'lab/sitemap', layout: false
end

def lab_contact_values
  {
    'name' => params[:name].to_s,
    'email' => params[:email].to_s,
    'company' => params[:company].to_s,
    'message' => params[:message].to_s
  }
end

def lab_contact_errors(values)
  errors = {}
  errors['name'] = 'Completa este campo con tu nombre.' if values['name'].strip.empty?
  errors['email'] = 'Completa este campo con tu correo electrónico.' if values['email'].strip.empty?
  if !values['email'].strip.empty? && !values['email'].match?(/\A[^@\s]+@[^@\s]+\.[^@\s]+\z/)
    errors['email'] = 'El correo electrónico no tiene un formato válido.'
  end
  errors['message'] = 'Completa este campo con tu mensaje.' if values['message'].strip.empty?
  errors
end

def render_lab_contact(values: {}, errors: {}, status_code: 200)
  @lab_title = 'Contacto | Kleer Lab'
  @lab_description = 'Cuéntanos tu desafío operativo. Te respondemos con un alcance acotado ' \
                     'en menos de 48 horas hábiles.'
  @lab_values = values
  @lab_errors = errors
  status status_code
  erb :'lab/contact', layout: :'lab/layout'
end

get '/contacto' do
  pass unless @is_lab

  render_lab_contact
end

post '/contacto' do
  pass unless @is_lab

  values = lab_contact_values

  unless verify_recaptcha
    return render_lab_contact(values: values, errors: { 'recaptcha' => 'Por favor verifica que no eres un robot.' },
                              status_code: 422)
  end

  errors = lab_contact_errors(values)
  return render_lab_contact(values: values, errors: errors, status_code: 422) if errors.any?

  send_mail(
    name: values['name'],
    email: values['email'],
    company: values['company'],
    message: values['message'],
    context: "lab.kleer.la: #{request.path}",
    language: 'es',
    resource_slug: '',
    initial_slug: '',
    can_we_contact: true,
    suscribe: false
  )

  redirect '/contacto/gracias', 303
end

get '/contacto/gracias' do
  pass unless @is_lab

  @lab_title = 'Gracias | Kleer Lab'
  @lab_description = 'Tu mensaje fue recibido. Te respondemos en menos de 48 horas hábiles.'
  erb :'lab/thanks', layout: :'lab/layout'
end

get '/casos/:slug' do
  pass unless @is_lab

  @case = LabCase.find_published(params[:slug])
  halt 404 unless @case

  @lab_title = lab_case_page_title(@case)
  @lab_description = lab_case_page_description(@case)
  @lab_og_type = 'article'
  @lab_head_extra = [
    lab_render_json_ld(lab_json_ld_for_case(@case)),
    lab_render_json_ld(lab_json_ld_breadcrumb_for_case(@case))
  ].join("\n")

  erb :'lab/case', layout: :'lab/layout'
end
