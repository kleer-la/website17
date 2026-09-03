require 'spec_helper'
require 'sinatra/flash'
require './app'
require './lib/services/mailer'

describe 'Kleer Lab subdomain' do
  def app
    Sinatra::Application.new
  end

  let(:lab_host) { { 'HTTP_HOST' => 'lab.kleer.la' } }

  before do
    # recaptcha_tags needs a configured site key; stub it out for view rendering.
    allow_any_instance_of(Sinatra::Application).to receive(:recaptcha_tags).and_return('')
  end

  describe 'GET / (home)' do
    it 'renders the Kleer Lab landing page with case links and Organization JSON-LD' do
      get '/', {}, lab_host

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('Kleer Lab')
      # Section anchors, not marketing copy: the wording is rewritten often,
      # the sections it has to render are what this example is about.
      expect(last_response.body).to include('id="que-resolvemos"')
      expect(last_response.body).to include('id="casos"')
      expect(last_response.body).to include('id="como-trabajamos"')
      expect(last_response.body).to include('id="que-recibes"')
      expect(last_response.body).to include('id="cuando-tiene-sentido"')
      expect(last_response.body).to include('/casos/cenped')
      expect(last_response.body).to include('"@type":"Organization"')
    end
  end

  describe 'GET /casos/:slug' do
    it 'renders a published case with Article and Breadcrumb JSON-LD' do
      get '/casos/cenped', {}, lab_host

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('Sushi Pop')
      expect(last_response.body).to include('"@type":"Article"')
      expect(last_response.body).to include('"@type":"BreadcrumbList"')
    end

    it 'returns 404 for an unknown case' do
      get '/casos/no-existe', {}, lab_host
      expect(last_response.status).to eq(404)
    end
  end

  describe 'GET /contacto' do
    it 'renders the contact form' do
      get '/contacto', {}, lab_host

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('Cuéntanos tu desafío')
      expect(last_response.body).to include('name="email"')
    end
  end

  describe 'POST /contacto' do
    let(:mailer_instance) { instance_double(Mailer) }

    before { allow(Mailer).to receive(:new).and_return(mailer_instance) }

    it 'forwards a valid submission to Keventer and redirects to gracias' do
      allow_any_instance_of(Sinatra::Application).to receive(:verify_recaptcha).and_return(true)

      expect(Mailer).to receive(:new).with(
        KeventerAPI.mailer_url,
        hash_including(
          name: 'Ana', email: 'ana@pyme.com', company: 'PyME',
          message: 'Quiero automatizar pedidos',
          context: 'lab.kleer.la: /contacto', language: 'es'
        )
      )

      post '/contacto',
           { name: 'Ana', email: 'ana@pyme.com', company: 'PyME', message: 'Quiero automatizar pedidos' },
           lab_host

      expect(last_response.status).to eq(303)
      expect(last_response.headers['Location']).to end_with('/contacto/gracias')
    end

    it 're-renders with a 422 when recaptcha fails' do
      allow_any_instance_of(Sinatra::Application).to receive(:verify_recaptcha).and_return(false)
      expect(Mailer).not_to receive(:new)

      post '/contacto', { name: 'Ana', email: 'ana@pyme.com', message: 'Hola' }, lab_host

      expect(last_response.status).to eq(422)
      expect(last_response.body).to include('no eres un robot')
    end

    it 're-renders with a 422 and validation errors when fields are missing or invalid' do
      allow_any_instance_of(Sinatra::Application).to receive(:verify_recaptcha).and_return(true)
      expect(Mailer).not_to receive(:new)

      post '/contacto', { name: '', email: 'bad-email', message: '' }, lab_host

      expect(last_response.status).to eq(422)
      expect(last_response.body).to include('Completa este campo con tu nombre')
      expect(last_response.body).to include('no tiene un formato')
    end
  end

  describe 'GET /sitemap.xml' do
    it 'lists the lab pages as XML' do
      get '/sitemap.xml', {}, lab_host

      expect(last_response.status).to eq(200)
      expect(last_response.headers['Content-Type']).to include('xml')
      expect(last_response.body).to include('lab.kleer.la/casos/cenped')
      expect(last_response.body).to include('lab.kleer.la/contacto')
    end
  end

  describe 'isolation from the main site' do
    it 'does not serve lab case routes on a non-lab host' do
      get '/casos/cenped' # default host is example.org
      expect(last_response.status).to eq(404)
    end
  end
end
