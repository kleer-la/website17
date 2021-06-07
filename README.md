Website (update 2017-2018)
---
En conjunto con nuestros amigos de Innqube.com (Mauro Strione), Cambá (Pablo de los Santos)
y actualmente la gran Alina Ryba    :)

Website
=======

Build & Coveralls
---
[![Build Status](https://travis-ci.org/kleer-la/website17.png?branch=master)](https://travis-ci.org/kleer-la/website17)
[![Coverage Status](https://coveralls.io/repos/github/kleer-la/website17/badge.svg?branch=master)](https://coveralls.io/github/kleer-la/website17?branch=master)

Code climate
---
[![Code Climate](https://codeclimate.com/github/kleer-la/website17/badges/gpa.svg)](https://codeclimate.com/github/kleer-la/website17)
[![Test Coverage](https://codeclimate.com/github/kleer-la/website17/badges/coverage.svg)](https://codeclimate.com/github/kleer-la/website17/coverage)
[![Issue Count](https://codeclimate.com/github/kleer-la/website17/badges/issue_count.svg)](https://codeclimate.com/github/kleer-la/website17)

CSS/SASS
---

Para trabajar los estilos ir a la carpeta app y correr:
sass --watch scss:css

Docker
---

Para desarrollar con docker
docker-compose run --service-ports website17 bash
cd app
gem install bundler:2.0.2
bundle install
ruby app.rb -o 0


Routes
---
rake routes