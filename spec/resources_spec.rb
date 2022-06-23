require './lib/resources'

TEST_RESOURCE = <<-JSON
{ "resources":
  [
    {"es": {
      "id": "kartas-conexion",
      "landing": "https://www.nataliadavidovich.com.ar/p/kartas-de-conexion.html",
      "cover": "/img/recursos/kartas-conexion.jpg",
      "title": "Kartas de Conexión",
      "description": "Mazo de cartas con distintos juegos para aumentar la conexión propia y con otras personas y desarrollar el vocabulario emocional.",
      "authors": "<a href='https://www.linkedin.com/in/nataliadavidovich/'>Natty Davidovich</a>",
      "share_fb": "u=https%3A%2F%2Fwww.nataliadavidovich.com.ar%2Fp%2Fkartas-de-conexion.html",
      "share_tw": "text=¿Te gustaría mejorar la conexión entre las personas de tu equipo? Te comparto el juego de Kartas de Conexión de @kleer_la. Descárgalas aquí https://www.nataliadavidovich.com.ar/p/kartas-de-conexion.html&hashtags=ComunicaciónColaborativa,CNV,ComunicaciónEfectiva",
      "share_li": "mini=true&url=https%3A%2F%2Fwww.nataliadavidovich.com.ar%2Fp%2Fkartas-de-conexion.html&title=Mejora%20la%20conexion%20entre%20las%20personas%20de%20tu%20equipo.%20Busca%20las%20cartas%20https%3A%2F%2Fwww.nataliadavidovich.com.ar%2Fp%2Fkartas-de-conexion.html%20%23ComunicacionColaborativa%20%23CNV%20%23ComunicacionEfectiva"
      }
    },
    {"es": {   
          "id": "guias-agiles",
          "landing": "https://guiasagiles.herokuapp.com/",
          "cover": "/img/recursos/guias-agiles.jpg",
          "title": "Guias Ágiles", 
          "description": "Un lugar, todas las guías: Técnicas y herramientas que potencian a personas y equipos.",
          "authors": "<a href='https://twitter.com/pablitux'>Pablo Tortorella</a> - <a href='https://twitter.com/hhiroshi'>Hiroshi Hiromoto</a>",
          "share_fb": "u=https%3A%2F%2Fkl.la%2Fguias-agiles",
          "share_tw": "text=¿Conoces la 22 guías de técnicas y herramientas que potencian a personas y equipos? Te comparto las GuiasAgiles, de @kleer_la. Busca la tuya y descárgarla aquí&url=https://kl.la/guias-agiles&hashtags=AgilidadOrganizacional,ReunionesProductivas,MasColaboracion,Agile,Scrum,equiposagiles",
          "share_li": "mini=true&url=https%3A%2F%2Fkl.la%2Fguias-agiles&title=%C2%BFConoces%20la%2022%20gu%C3%ADas%20de%20t%C3%A9cnicas%20y%20herramientas%20que%20potencian%20a%20personas%20y%20equipos%3F%20Te%20comparto%20las%20%23GuiasAgiles%20de%20Kleer.%20Busca%20la%20tuya%20y%20desc%C3%A1rgarla%20aqu%C3%AD%20https%3A%2F%2Fkl.la%2Fguias-agiles%20%23AgilidadOrganizacional%20%20%23ReunionesProductivas%20%23MasColaboracion%20%23Agile%20%23Scrum%20%23equiposagiles",
          "comments": ""
          }
    }
  ]
}
JSON


describe Resources do
  it 'empty' do
    resources = Resources.new
    expect(resources.all).to eq []
  end
  it 'read resources' do
    resources = Resources.new
    resources.load(TEST_RESOURCE)
    # p resources.all
    expect(resources.all.count).to be > 0
  end
  it 'read default resources' do
    resources = Resources.new
    resources.load
    # p resources.all
    expect(resources.all.count).to be > 0
  end
  it 'a resources has es title' do
    resource = Resources.new
      .load(TEST_RESOURCE)
      .all
    expect(resource[0]['es']['title'].length).to be > 0
  end
  it 'there are some English content' do
    resource = Resources.new.load.all
    expect(resource.filter { |r| r['en']}).not_to eq []
  end
end
