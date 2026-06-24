# AI Summit Bogotá 2026 campaign has ended. Permanently redirect the old
# landing URL to the related training offering.
get '/ai-summit' do
  redirect '/es/formacion/adopcion-ia-empresas', 301
end
