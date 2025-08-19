#!/bin/bash
# TODO: Migrate to Dart Sass for better performance and continued support
# Current: Using Ruby Sass (deprecated as of March 2019)
# Future: Use Dart Sass -> sass --watch scss/index.scss:css/index.css --style compressed
# Install: npm install -g sass  or  use standalone binary

cd public/app
sass --watch scss/index.scss:css/index.css --style compressed
sass --watch scss/podcasts.scss:css/podcasts.css --style compressed
cd ../..