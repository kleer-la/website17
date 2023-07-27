require './lib/clients'

get '/clientes' do
  @meta_tags.set! title: "#{t('meta_tag.clients.title')}",
                  description: "#{t('meta_tag.clients.description')}",
                  canonical: "#{t('meta_tag.clients.canonical')}"

  @clients =  client_list

  erb :'clients/index', layout: :'layout/layout2022'
end
