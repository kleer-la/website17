require 'spec_helper'
require './app'
require 'nokogiri'

# The Services menu and the "Qué hacemos" footer list the service areas as
# Keventer names and orders them, per language, so renaming an area (Producto
# Digital, kleer-marketing#26) renames its entry with no deploy.
describe 'the service areas in the menu and the footer' do
  def app
    Sinatra::Application.new
  end

  def area(slug, name, lang)
    ServiceAreaV3.new.load_from_json('slug' => slug, 'name' => name, 'lang' => lang, 'services' => [])
  end

  let(:areas) do
    [area('cambio-organizacional-liderazgo', 'Cambio Organizacional y Liderazgo', 'es'),
     area('producto-digital', 'Producto Digital', 'es'),
     area('product-management', 'Product Management', 'en')]
  end

  before do
    CacheService.instance.clear
    allow(Page).to receive(:load_from_keventer).and_return(Page.new)
    allow(ServiceAreaV3).to receive(:try_create_list_keventer).and_return(areas)
  end

  def links(css)
    Nokogiri::HTML(last_response.body).css(css).map { |a| [a.text.strip, a['href']] }
  end

  it 'lists the areas of the language in the menu, in their order, named as Keventer names them' do
    get '/es/'

    menu = links('#navbar .dropdown-menu a')
    expect(menu.index(['Cambio Organizacional y Liderazgo', '/es/servicios/cambio-organizacional-liderazgo']))
      .to be < menu.index(['Producto Digital', '/es/servicios/producto-digital'])
    expect(menu.map(&:first)).not_to include('Product Management', 'service-areas')
  end

  it 'lists them in the footer too, with their full name, before the fixed entries' do
    get '/es/'

    footer = links('footer a')
    expect(footer.index(['Producto Digital', '/es/servicios/producto-digital']))
      .to be < footer.index(['Programas de Capacitación', '/es/formacion/programas-capacitacion-empresarial'])
    expect(footer.map(&:first)).not_to include('service-areas')
  end

  it 'lists the English areas under /services in English' do
    get '/en/'

    menu = links('#navbar .dropdown-menu a')
    expect(menu).to include(['Product Management', '/en/services/product-management'])
    expect(menu.map(&:first)).not_to include('Producto Digital')
  end
end
