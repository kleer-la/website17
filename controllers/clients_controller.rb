require './lib/clients'

get '/clientes' do
  @meta_tags.set! title: "#{@base_title} #{t('meta_tag.clients.title')}",
                  description: "#{t('meta_tag.clients.description')}",
                  canonical: "#{session[:locale]}#{t('meta_tag.clients.canonical')}"

  @clients =  client_list

  erb :'clients/index', layout: :'layout/layout2022'
  # erb :clientes
end
