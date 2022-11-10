require './lib/clients'

get '/clientes' do
  @meta_tags.set! title: "#{@base_title} | Nuestros clientes"
  @meta_tags.set! description: 'Kleer - Coaching & Training - Estas organizaciones confían en nosotros'

  @clients =  client_list

  erb :'clients/index', layout: :'layout/layout2022'
  # erb :clientes
end
