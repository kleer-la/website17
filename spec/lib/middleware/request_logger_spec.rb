require 'spec_helper'
require_relative '../../../lib/middleware/request_logger'

RSpec.describe Middleware::RequestLogger do
  let(:inner_app) { ->(_env) { [status, { 'Content-Type' => 'text/html' }, ['OK']] } }
  let(:app) { described_class.new(inner_app) }
  let(:status) { 200 }
  let(:output) { StringIO.new }

  before { $stdout = output }
  after { $stdout = STDOUT }

  def env_for(path, method: 'GET', host: 'www.kleer.la')
    {
      'REQUEST_METHOD' => method,
      'PATH_INFO' => path,
      'QUERY_STRING' => '',
      'HTTP_HOST' => host,
      'REMOTE_ADDR' => '127.0.0.1'
    }
  end

  it 'logs requests as JSON with required fields' do
    app.call(env_for('/es/blog'))
    log = JSON.parse(output.string)

    expect(log['method']).to eq('GET')
    expect(log['path']).to eq('/es/blog')
    expect(log['status']).to eq(200)
    expect(log['level']).to eq('info')
    expect(log['duration_ms']).to be_a(Numeric)
    expect(log['timestamp']).to match(/^\d{4}-\d{2}-\d{2}T/)
  end

  context 'when status is 404' do
    let(:status) { 404 }

    it 'logs with warn level' do
      app.call(env_for('/nonexistent'))
      log = JSON.parse(output.string)

      expect(log['status']).to eq(404)
      expect(log['level']).to eq('warn')
    end
  end

  context 'when status is 500' do
    let(:status) { 500 }

    it 'logs with error level' do
      app.call(env_for('/broken'))
      log = JSON.parse(output.string)

      expect(log['status']).to eq(500)
      expect(log['level']).to eq('error')
    end
  end

  it 'skips static assets' do
    app.call(env_for('/images/logo.png'))
    expect(output.string).to be_empty
  end

  it 'includes query string when present' do
    env = env_for('/search')
    env['QUERY_STRING'] = 'q=scrum'
    app.call(env)
    log = JSON.parse(output.string)

    expect(log['query']).to eq('q=scrum')
  end

  it 'omits nil fields' do
    app.call(env_for('/es/'))
    log = JSON.parse(output.string)

    expect(log).not_to have_key('query')
    expect(log).not_to have_key('referer')
  end
end
