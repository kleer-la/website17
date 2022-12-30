TEST_COUNT=1000
PATH_TO_HIT=/es/ bundle exec derailed exec $1
PATH_TO_HIT=/es/blog bundle exec derailed exec $1
PATH_TO_HIT=/es/agenda bundle exec derailed exec $1
PATH_TO_HIT=/es/catalogo bundle exec derailed exec $1
PATH_TO_HIT=/es/agilidad-organizacional bundle exec derailed exec $1

TEST_COUNT=1500
PATH_TO_HIT=/es/somos bundle exec derailed exec $1
PATH_TO_HIT=/es/prensa bundle exec derailed exec $1
PATH_TO_HIT=/es/clientes bundle exec derailed exec $1
PATH_TO_HIT=/es/recursos bundle exec derailed exec $1
