get '/membresia-ia' do
  @meta_tags.set! title: 'Membresía de Adopción de IA - Kleer',
                  description: 'Acompañamiento continuo para hacer que la IA funcione en el día a día de tu organización. Membresía mensual con dedicación operativa y estratégica.',
                  noindex: true,
                  nofollow: true

  erb :'membership/index', layout: :'layout/layout2022'
end
