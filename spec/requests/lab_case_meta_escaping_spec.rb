require 'spec_helper'
require './app'

# A case whose description is built from its pulled quote arrives with double
# quotes around it, and the meta tags put it inside a double-quoted attribute.
# Unescaped, the attribute closes on the first quote of the text: the page ends
# up with an empty description and the rest of the sentence parsed as stray
# attributes.
describe 'a case with a pulled quote keeps its description' do
  fixtures_dir = File.expand_path('../fixtures/lab_cases', __dir__)

  def app
    Sinatra::Application.new
  end

  let(:lab_host) { { 'HTTP_HOST' => 'lab.kleer.la' } }

  around do |example|
    LabCase.cases_dir = fixtures_dir
    LabCase.allow_drafts = false
    example.run
  ensure
    LabCase.cases_dir = nil
    LabCase.allow_drafts = nil
  end

  it 'escapes the quotes instead of ending the attribute on them' do
    get '/casos/quote_full', {}, lab_host

    expect(last_response.status).to eq(200)
    expect(last_response.body).not_to include('content=""Ahora')
    expect(last_response.body)
      .to include('content="&quot;Ahora gestiono todo en tiempo real&quot;. Comercio exterior. Caso Kleer Lab."')
  end

  it 'says the same thing to social cards' do
    get '/casos/quote_full', {}, lab_host

    expect(last_response.body).to include('property="og:description" content="&quot;Ahora')
    expect(last_response.body).to include('name="twitter:description" content="&quot;Ahora')
  end
end
