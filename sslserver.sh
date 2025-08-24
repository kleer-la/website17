set -a;source ./website.env;set +a
RACK_ENV=development puma -C config/puma.rb
# rerun  --signal TERM --pattern '**/*.{rb,json,ru,yml,slim,md,c,h}' "RACK_ENV=development WEB_CONCURRENCY=0 puma -C config/puma.rb"
# rerun --pattern '**/*.{rb,json,ru,yml,slim,md,c,h}' "ruby app.rb -o 0.0.0.0"
