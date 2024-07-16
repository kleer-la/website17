require './lib/clients'

# get '/clientes' do
#   @meta_tags.set! title: "#{t('meta_tag.clients.title')}",
#                   description: "#{t('meta_tag.clients.description')}",
#                   canonical: "#{t('meta_tag.clients.canonical')}"

#   @clients =  client_list

#   erb :'clients/index', layout: :'layout/layout2022'
# end
get '/clientes' do
  @meta_tags.set! title: t('meta_tag.clients.title').to_s,
                  description: t('meta_tag.clients.description').to_s,
                  canonical: t('meta_tag.clients.canonical').to_s

  @clients = client_list
  @stories = success_stories
  erb :'clients/index_ng', layout: :'layout/layout2022'
end

get '/clientes/testimonios/:id' do
  story = success_stories(params[:id])
  return(redirect_not_found_testimony) if story.nil?

  @meta_tags.set! title: story[:title],
                  description: story[:meta_desdription],
                  canonical: request.path
  erb :'clients/success_story', locals: { story: story }, layout: :'layout/layout2022'
end

def redirect_not_found_testimony
  session[:error_msg] = I18n.t('page_not_found')
  flash.now[:alert] = I18n.t('page_not_found')
  redirect(to("/#{session[:locale]}/clientes"))
end
