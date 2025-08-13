set -a;source ./website.env;set +a
KEVENTER_URL="http://eventer_devcontainer-app-1:3000" rerun --pattern '**/*.{rb,json,ru,yml,slim,md,c,h}' "ruby app.rb -o 0.0.0.0"
