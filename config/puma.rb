workers ENV.fetch('WEB_CONCURRENCY', 2)
preload_app!
port ENV.fetch('PORT', 4567)

# Enable HTTPS with HTTP/2 in development only
if ENV['RACK_ENV'] == 'development'
  puts 'In development mode: Enabling HTTPS with HTTP/2'
  ssl_bind '0.0.0.0', '8443', {
    cert: './certs/localhost.crt', # Path to certificate in devcontainer
    key: './certs/localhost.key',  # Path to private key in devcontainer
    ssl_version: :TLSv1_2
  }
end