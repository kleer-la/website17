if ENV['RACK_ENV'] == 'development'
  workers 0 # Disable workers in development
  preload_app! false # Disable preloading in development
  puts 'In development mode: Enabling HTTPS with HTTP/2'
  ssl_bind '0.0.0.0', '8443', {
    cert: './certs/localhost.crt',
    key: './certs/localhost.key',
    ssl_version: :TLSv1_2
  }
else
  workers ENV.fetch('WEB_CONCURRENCY', 2)
  preload_app!
end

port ENV.fetch('PORT', 4567)
