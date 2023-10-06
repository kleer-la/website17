require './lib/services/file_store_service'

get '/certificado' do
  search_term = params['q']
  erb :'certificates/certificate_form', layout: :'layout/layout2022', locals: { search_term: search_term }
end

post '/certificado' do
  search_term = params['q']
  image_url = 'https://s3.amazonaws.com/Keventer/certificates/1FED58170580587F3AABp50117-A4.pdf'

  store = FileStoreService.create_s3
  filename = store.read image_url, ''

  erb :'certificates/certificate', layout: :'layout/layout2022', locals: { image_url: filename }
end
