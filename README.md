Website (update 2022)
---
En conjunto con nuestros amigos de Innqube.com (Mauro Strione), Cambá (Pablo de los Santos)
y actualmente la gran Alina Ryba    :)

Website
=======

Build & Coveralls
---
![Build Status](https://github.com/kleer-la/website17/actions/workflows/ci.yml/badge.svg?branch=master)
[![Coverage Status](https://coveralls.io/repos/github/kleer-la/website17/badge.svg?branch=master)](https://coveralls.io/github/kleer-la/website17?branch=master)

Code climate
---
[![Code Climate](https://codeclimate.com/github/kleer-la/website17/badges/gpa.svg)](https://codeclimate.com/github/kleer-la/website17)
[![Test Coverage](https://codeclimate.com/github/kleer-la/website17/badges/coverage.svg)](https://codeclimate.com/github/kleer-la/website17/coverage)
[![Issue Count](https://codeclimate.com/github/kleer-la/website17/badges/issue_count.svg)](https://codeclimate.com/github/kleer-la/website17)

CSS/SASS
---

Para trabajar los estilos ir a la carpeta public/app y correr:
```cli
gem install sass
sass --watch scss:css
```
y forzar refresco Crtl+Shft+R

Docker
---

Para desarrollar con docker
```cli
docker-compose run --service-ports website17 bash
bundle install
# ruby app.rb -o 0
puma -p 4567
```

Routes
```cli
rake routes
```

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

MetaTags inspirado en https://github.com/kpumuk/meta-tags

Deploy Heroku sin pipeline
```cli
# una vez - ambiente test (qa2.kleer.la)
heroku git:remote -a kleer-test
git remote rename heroku heroku-test
# cada deploy a test
git push heroku-test develop:main
```

```cli
# una vez - ambiente prod (www.kleer.la)
heroku git:remote -a kleer
# cada deploy a prod
git push heroku master:main
```

== Imagenes
    sudo apt-get install imagemagick
    convert ubuntuhandbook.png -quality 90 ubuntuhandbook.jpg

    sudo apt-get install webp
    cwebp -q 80 input.png -o output.webp
