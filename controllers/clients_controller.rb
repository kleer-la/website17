require './lib/clients'

get '/clientes' do
  @meta_tags.set! title: "#{t('meta_tag.clients.title')}",
                  description: "#{t('meta_tag.clients.description')}",
                  canonical: "#{t('meta_tag.clients.canonical')}"

  @clients =  client_list

  erb :'clients/index', layout: :'layout/layout2022'
end
get '/clientes_ng' do
  @meta_tags.set! title: "#{t('meta_tag.clients.title')}",
                  description: "#{t('meta_tag.clients.description')}",
                  canonical: "#{t('meta_tag.clients.canonical')}"

  @clients = client_list
  @stories = success_stories
  erb :'clients/index_ng', layout: :'layout/layout2022'
end

get '/clientes/historias/:id' do
  @story = success_stories(params[:id])
  @meta_tags.set! title:       "", #     "#{t('meta_tag.clients.title')}",
                  description: "", #     "#{t('meta_tag.clients.description')}",
                  canonical:   "" #     "#{t('meta_tag.clients.canonical')}"
  erb :'clients/success_story', locals: { story: @story }, layout: :'layout/layout2022'
end
