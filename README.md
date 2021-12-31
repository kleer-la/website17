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
```cli
gem install sass
sass --watch scss:css
```

Docker
---

Para desarrollar con docker
```cli
docker-compose run --service-ports website17 bash
bundle install
ruby app.rb -o 0
```

Routes
```cli
rake routes
```

Referencias para configurar el Wordpress por reverse proxy
* https://www.cloudanix.com/blog/wordpress-installation-on-a-subdirectory-of-an-existing-app-ruby-on-rails/
* https://medium.com/@technoblogueur/wordpress-blog-for-ruby-on-rails-the-configuration-that-worked-for-me-a8a7a989a68d
* https://www.netlingshq.com/blog/wordpress-with-ruby-on-rails/


Soporte de HTTP/2?
```cli
curl -sI https://www.kleer.la -o/dev/null -w '%{http_version}\n'
```

WebP
```cli
sudo apt install webp
cwebp public/app/img/slide01.jpg -o public/app/img/slide01.webp
```
https://web.dev/serve-images-webp/