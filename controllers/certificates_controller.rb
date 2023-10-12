require './lib/services/file_store_service'

get '/certificado' do
  search_term = params['q']
  erb :'certificates/certificate_form', layout: :'layout/layout2022', locals: { search_term: search_term }
end

post '/certificado' do
  search_term = params['q']
  # image_url = 'https://s3.amazonaws.com/Keventer/certificates/1FED58170580587F3AABp50117-A4.pdf'
  # image_url = 'https://s3.amazonaws.com/Keventer/certificates/00088859CA15F1EAEB7Fp20174-LETTER.pdf'
  # filename = search_term+'.pdf'
  # store = FileStoreService.create_s3
  # filename = store.read filename, 'LETTER', 'certificates'
  filename = get_certificate(search_term)

  if filename.nil?
    session[:error_msg] = flash[:error] = 'No encontramos un certificado con ese código'

    return erb :'certificates/certificate_form', layout: :'layout/layout2022', locals: { search_term: search_term }
  end

  erb :'certificates/certificate', layout: :'layout/layout2022', locals: { image_url: filename }
end

get '/tmp/:filename' do
  filename = params['filename']
  send_file File.join('/tmp', filename)
end

def get_certificate(certification_id)
  return nil if certification_id.to_s == ''
  
  store = FileStoreService.create_s3

  # certification_id += '.pdf'
  # filename = nil
  # begin
  #   filename = store.read certification_id, 'LETTER', 'certificates'
  # rescue ArgumentError => exception
  #   begin
  #     filename = store.read certification_id, nil, 'certificates'
  #   rescue ArgumentError => exception
  #   end
  # end
  # filename

  store.find_certificate(certification_id)
end