require './lib/keventer_reader'

Given(/^I open the web app$/) do
  visit '/'
end

When(/^I click on "(.*)"$/) do |text|
  click_link(text)
end

Then(/^I should see "(.*)"$/) do |text|
  expect(page).to have_text text
end

Then(/^I should see "(.*)" in a phone$/) do |text|
  last_response.body.should have_selector('.visible-xs') { |div|
                              div.should contain text
                            }
end

Then(/^I should not see "(.*?)"$/) do |text|
  expect(page).to_not have_content text
end

When(/^I fill "(.*)" with "(.*)"$/) do |field, value|
  fill_in(field, with: value)
end

When(/^I press "(.*)"$/) do |name|
  click_button(name)
end

When(/^I visit the home page$/) do
  stub_connector
  visit '/'
end

Given(/^I visit the spanish home page$/) do
  stub_connector
  visit '/es/'
end

Given(/^I visit the english home page$/) do
  stub_connector
  visit '/en/'
end

When('I switch to {string}') do |lang_long|
  lang = if lang_long == 'ENGLISH'
           'en'
         else
           'es'
         end
  # change_to_en_top
  click_link("change_to_#{lang}_top")
end

Given(/^I visit the english "(.*?)"$/) do |page|
  stub_connector
  visit "/en/#{page}"
end

Given(/^I visit "(.*?)"$/) do |page_url|
  visit page_url
end

Then(/^I should see the json string for all of the events$/) do
  text = '\"aaData\": \[' \
         '\[\"<span class=\\\"label label-info\\\">09<br><span class=\\\"lead\\\">Ene</span></span>\",\"<a href=\\\"/es/entrenamos/evento/44-workshop-de-retrospectivas-buenos-aires\\\">Workshop de Retrospectivas</a><br/><img src=\\\"/img/flags/ar.png\\\"/> Buenos Aires, Argentina\",\"<a href=\\\"https://eventioz.com.ar/retrospectivas-9-ene-2012/registrations/new\\\" target=\\\"_blank\\\" class=\\\"btn btn-success\\\">¡Me interesa!</a>\"\],' \
         '\[\"<span class=\\\"label label-info\\\">31<br><span class=\\\"lead\\\">Ene</span></span>\",\"<a href=\\\"/es/entrenamos/evento/47-certified-scrummaster-\(csm\)-lima\\\">Certified ScrumMaster \(CSM\)</a><br/><img src=\\\"/img/flags/pe.png\\\"/> Lima, Peru\",\"<a href=\\\"http://www.openedgetech.com/calendario\\\" target=\\\"_blank\\\" class=\\\"btn btn-success\\\">¡Me interesa!</a>\"\]' \
         '\]'
  last_response.body.should =~ /#{text}/m
end

Then(/^I should see the json string for the Argentina events$/) do
  text = '\"aaData\": \[' \
         '\[\"<span class=\\\"label label-info\\\">09<br><span class=\\\"lead\\\">Ene</span></span>\",\"<a href=\\\"/es/entrenamos/evento/44-workshop-de-retrospectivas-buenos-aires\\\">Workshop de Retrospectivas</a><br/><img src=\\\"/img/flags/ar.png\\\"/> Buenos Aires, Argentina\",\"<a href=\\\"https://eventioz.com.ar/retrospectivas-9-ene-2012/registrations/new\\\" target=\\\"_blank\\\" class=\\\"btn btn-success\\\">¡Me interesa!</a>\"\]' \
         '\]'
  last_response.body.should =~ /#{text}/m
end

Then(/^I should see the json string for the Bolivia events$/) do
  text = '\"aaData\": \[' \
         '\[\"<span class=\\\"label label-info\\\">16<br><span class=\\\"lead\\\">Ene</span></span>\",\"<a href=\\\"/es/entrenamos/evento/48-comunicacion-efectiva-en-proyectos-de-software-webinar\\\">Comunicacion Efectiva en Proyectos de Software</a><br/><img src=\\\"/img/flags/ol.png\\\"/> Webinar, -- OnLine --\",\"<a href=\\\"https://eventioz.com.ar/webinar-com-efectiva-16-ene/registrations/new\\\" target=\\\"_blank\\\" class=\\\"btn btn-success\\\">¡Me interesa!</a>\"\],' \
         '\[\"<span class=\\\"label label-info\\\">23<br><span class=\\\"lead\\\">Ene</span></span>\",\"<a href=\\\"/es/entrenamos/evento/58-webinar-de-tdd-intermedio-webinar\\\">Webinar de TDD Intermedio</a><br/><img src=\\\"/img/flags/ol.png\\\"/> Webinar, -- OnLine --\",\"<a href=\\\"https://eventioz.com.ar/web-tdd1-201301\\\" target=\\\"_blank\\\" class=\\\"btn btn-success\\\">¡Me interesa!</a>\"\],' \
         '\[\"<span class=\\\"label label-info\\\">20<br><span class=\\\"lead\\\">Feb</span></span>\",\"<a href=\\\"/es/entrenamos/evento/59-webinar-de-tdd-avanzado-webinar\\\">Webinar de TDD Avanzado</a><br/><img src=\\\"/img/flags/ol.png\\\"/> Webinar, -- OnLine --\",\"<a href=\\\"https://eventioz.com.ar/web-tdd2-201302\\\" target=\\\"_blank\\\" class=\\\"btn btn-success\\\">¡Me interesa!</a>\"\],' \
         '\[\"<span class=\\\"label label-info\\\">07<br><span class=\\\"lead\\\">Mar</span></span>\",\"<a href=\\\"/es/entrenamos/evento/54-certified-scrummaster-\(csm\)-cochabamba\\\">Certified ScrumMaster \(CSM\)</a><br/><img src=\\\"/img/flags/bo.png\\\"/> Cochabamba, Bolivia\",\"<a href=\\\"https://docs.google.com/a/kleer.la/spreadsheet/viewform?formkey=dEF0Qmp2dUphN1pqRGtldFVLeGV6RXc6MA#gid=0\\\" target=\\\"_blank\\\" class=\\\"btn btn-success\\\">¡Me interesa!</a>\"\],' \
         '\[\"<span class=\\\"label label-info\\\">25<br><span class=\\\"lead\\\">Mar</span></span>\",\"<a href=\\\"/es/entrenamos/evento/56-certified-scrum-developer-\(csd-track-completo\)-santa-cruz-de-la-sierra\\\">Certified Scrum Developer \(CSD Track Completo\)</a><br/><img src=\\\"/img/flags/bo.png\\\"/> Santa Cruz de la Sierra, Bolivia\",\"<a href=\\\"https://docs.google.com/a/kleer.la/spreadsheet/viewform?formkey=dFk5ZUtrWlE5SUw2elJyNjQ3ZHR2bUE6MA#gid=0\\\" target=\\\"_blank\\\" class=\\\"btn btn-success\\\">¡Me interesa!</a>\"\],' \
         '\[\"<span class=\\\"label label-info\\\">01<br><span class=\\\"lead\\\">Abr</span></span>\",\"<a href=\\\"/es/entrenamos/evento/57-certified-scrum-developer-\(csd-track-completo\)-cochabamba\\\">Certified Scrum Developer \(CSD Track Completo\)</a><br/><img src=\\\"/img/flags/bo.png\\\"/> Cochabamba, Bolivia\",\"<a href=\\\"https://docs.google.com/a/kleer.la/spreadsheet/viewform?formkey=dFdfYlJhQzlVWG9uWk5yODRGVDcxVGc6MA#gid=0\\\" target=\\\"_blank\\\" class=\\\"btn btn-success\\\">¡Me interesa!</a>\"\]' \
         '\]'
  last_response.body.should =~ /#{text}/m
end

Then(/^I should see the json string with no events$/) do
  text = '\"aaData\": \[\]'
  last_response.body.should =~ /#{text}/m
end

When(/^I visit the plain event page$/) do
  visit '/entrenamos/evento/44/remote'
end

Then(/^I should be on Entrenamos page$/) do
  current_url.should == '/entrenamos'
end

Then(/^I should see a link to "(.*?)" with text "(.*?)"$/) do |url, text|
  response_body.should have_selector("a[href='#{url}']") do |element|
    element.should contain(text)
  end
end

Then(/^I should see an image pointing to "(.*?)"$/) do |url|
  response_body.should have_selector("img[src='#{url}']")
end

Then(/^the page title should be "(.*?)"$/) do |title_text|
  expect(page).to have_title title_text
end

Given(/^I visit the "(.*?)" page$/) do |page_url|
  stub_connector
  visit "/#{page_url}"
  #  expect(page).to have_css('locator_present_only_at_second_page')
end

Given(/^I visit the "(.*?)" categoria page$/) do |codename|
  stub_connector
  visit "/categoria/#{codename}"
end
# I visit the "xxx" ajax page (todos)
# I visit the "xxx" ajax page for Blabla (ba)
# I visit the "xxx" ajax page not very valid (otro)
When(/^I visit the "(.*?)" ajax page ([^()]+)?\((.*?)\)$/) do |page, _dummy, filter|
  visit "/#{page}/eventos/pais/#{filter}"
end

Then(/^I should see a tweet button$/) do
  response_body.should have_selector('script') do |element|
    element.should contain('//platform.twitter.com/widgets.js')
    element.should contain('twitter-wjs')
  end
  response_body.should have_selector("a[href='https://twitter.com/share']") do |element|
    element.should contain('Tweet')
  end
end

Given(/^I visit the last tweet url for "(.*?)"$/) do |screen_name|
  visit "/last-tweet/#{screen_name}"
end

Then(/^I should see a tweet "(.*?)"$/) do |tweet|
  response_body.should be == tweet
end

Then(/^I should see a facebook like button$/) do
  response_body.should have_selector('script') do |element|
    element.should contain('//connect.facebook.net/es_LA/all.js')
  end
  response_body.should have_selector("div[class='fb-like']")
end

Then(/^I should see the Subscribe to newsletter option$/) do
  response_body.should have_selector("input[value='SUSCRÍBETE']")
end

Then(/^I should see all countries highlited$/) do
  expect(find("ul[id='country-filter']")
          .find("li[class='active']")
          .find('a')).to have_text 'Todos'
end

Then(/^I should see a linkedin link for a Kleerer with LinkedIn$/) do
  expect(page).to have_selector("a[href='https://www.linkedin.com/in/jgabardini']")
end

Then(/^I should get a (\d+) error$/) do |error_code|
  expect(page.status_code).to eq error_code.to_i
end

Given(/^I visit the former Introducción a Scrum Page$/) do
  visit '/entrenamos/introduccion-a-scrum'
end

Given(/^I visit the former Introducción a Scrum spanish Page$/) do
  visit '/es/entrenamos/introduccion-a-scrum'
end

Given(/^I visit the former Desarrollo Agil Page$/) do
  visit '/entrenamos/desarrollo-agil-de-software'
end

Given(/^I visit the former Desarrollo Agil spanish Page$/) do
  visit '/es/entrenamos/desarrollo-agil-de-software'
end

Given(/^I visit the former Estimación y Planificación con Scrum Page$/) do
  visit '/entrenamos/estimacion-y-planificacion-con-scrum'
end

Given(/^I visit the former Estimación y Planificación con Scrum spanish Page$/) do
  visit '/es/entrenamos/estimacion-y-planificacion-con-scrum'
end

Given(/^I visit the international payment page$/) do
  visit '/preguntas-frecuentes/facturacion-pagos-internacionales'
end

Given(/^I visit the argentinian payment page$/) do
  visit '/preguntas-frecuentes/facturacion-pagos-argentina'
end

Given(/^I visit the colombian payment page$/) do
  visit '/preguntas-frecuentes/facturacion-pagos-colombia'
end

Given(/^I visit the CSM QnA page$/) do
  visit '/preguntas-frecuentes/certified-scrum-master'
end

Given(/^I visit the CSD QnA page$/) do
  visit '/preguntas-frecuentes/certified-scrum-developer'
end

Given(/^I visit an invalid Page$/) do
  visit '/bazzzzingaaaa'
end

Given(/^I visit the former entrenamos spanish Page$/) do
  visit '/es/entrenamos'
end

Then(/^I should be redirected to entrenamos Page$/) do
  expect(last_response.redirection?).to be_truthy
  last_response.location.gsub('https://example.org', '').should == '/entrenamos'
end

When(/^I visit a non existing event page$/) do
  visit '/entrenamos/evento/1-un-evento-inexistente'
end

When(/^I visit a non existing popup event page$/) do
  visit '/entrenamos/evento/1-un-evento-inexistente/remote'
end

Then(/^I should have a link to the "(.*?)" page$/) do |event_type_name|
  response_body.should have_selector("a[text()='#{event_type_name}']") do |element|
    element[0]['href'].should == "/cursos/1-#{ERB::Util.url_encode(event_type_name)}"
  end
end

Then(/^I should see the Argentinian fiscal data QR$/) do
  expect(page).to have_selector("img[src='https://www.afip.gob.ar/images/f960/DATAWEB.jpg']")
end

Then(/^I should see the Argentinian fiscal data link$/) do
  expect(page).to have_selector("a[target='_F960AFIPInfo']")
end

Given(/^I visit the Privacy page$/) do
  visit '/es/privacy'
end

Given(/^I visit the Terms page$/) do
  visit '/es/terms'
end

Given(/^I go to the Blog page$/) do
  visit '/es/blog'
end

Given(/^I navigate to "(.*?)"$/) do |ruta|
  visit "/es/#{ruta}/"
end
