set -a;. ./website.env;set +a
rerun "ruby app.rb -o 0"
