
get '/clientes' do
  meta_tags! title: "#{@base_title} | Nuestros clientes"
  meta_tags! description: 'Kleer - Coaching & Training - Estas organizaciones confían en nosotros'

  erb :'clients/index', layout: :'layout/layout2022'
  # erb :clientes
end
