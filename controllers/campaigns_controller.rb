get '/ai-summit' do
  @meta_tags.set! title: 'AI Summit Bogotá 2026 | Kleer',
                  description: 'Pasa de ideas de IA a resultados reales en semanas. Sesión de diagnóstico gratuita durante el AI Summit Bogotá 2026.',
                  canonical: 'https://www.kleer.la/ai-summit'

  erb :'campaigns/ai_summit_bogota_2026', layout: false
end
