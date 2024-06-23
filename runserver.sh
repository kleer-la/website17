set -a;source ./website.env;set +a
rerun --pattern '**/*.{rb,json,ru,yml,slim,md,c,h}' "ruby app.rb -o 0.0.0.0"
