require './lib/clients'

get('/home2022') { session[:version] = 2022; home }

get('/') {  session[:version] = 2021;  home}

def home
  @meta_tags.set!  title: t('meta_tag.home.title'),
                   description: t('meta_tag.home.description'),
                   canonical:  "#{session[:locale]}/"


  @clients =  client_list
  @coming_courses = if session[:locale] == 'es'
                      coming_courses
                    else
                      fake_event_from_catalog(KeventerReader.instance.categories)
                    end

  erb :'home/index', layout: :'layout/layout2022'
end


not_found do
  @meta_tags.set! title: t('page_not_found')

  erb :'home/error_404', layout: :'layout/layout2022'
end
