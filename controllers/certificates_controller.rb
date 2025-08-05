require './lib/services/file_store_service'

# Certificate validation routes - handles both /certificado (Spanish) and /certificate (English)
get %r{/(certificado|certificate)/?} do
  search_term = params['q']
  erb :'certificates/certificate_form', layout: :'layout/layout2022', locals: { search_term: search_term }
end

post %r{/(certificado|certificate)/?} do
  search_term = params['q']
  filename = get_certificate(search_term)

  if filename.nil?
    session[:error_msg] = flash[:error] = t('certificates.not_found')

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

  store.find_certificate(certification_id)
end
