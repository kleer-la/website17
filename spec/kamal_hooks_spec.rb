require 'spec_helper'
require 'json'
require 'open3'
require 'socket'
require 'tmpdir'

# Kamal runs .kamal/hooks/* on the machine that deploys. A QA deploy runs the
# performance specs and records the commit when they pass (post-deploy); a
# production deploy only goes ahead for a recorded commit (pre-deploy).
#
# The record lives in two places: a file on the machine that deployed QA, and
# a `perf/qa` commit status on GitHub that anyone deploying can read. The
# GitHub API is replaced here by a local server that answers what each test
# sets and keeps what it received.
# Just enough HTTP for the hooks: answers GET with `statuses`, keeps POSTs.
class FakeGitHub
  attr_reader :posts, :url
  attr_accessor :statuses

  def initialize
    @statuses = []
    @posts = []
    @server = TCPServer.new('127.0.0.1', 0)
    @url = "http://127.0.0.1:#{@server.addr[1]}"
    @thread = Thread.new { loop { serve(@server.accept) } }
  end

  def stop
    @thread.kill
    @server.close
  end

  private

  def serve(client)
    verb, path, headers, body = read_request(client)
    if verb == 'POST'
      @posts << { path: path, auth: headers['authorization'], body: JSON.parse(body) }
      reply(client, 201, '{}')
    else
      reply(client, 200, JSON.generate(@statuses))
    end
  ensure
    client.close
  end

  def read_request(client)
    verb, path = client.gets.split
    headers = {}
    while (line = client.gets) && line != "\r\n"
      key, value = line.split(': ', 2)
      headers[key.downcase] = value.strip
    end
    [verb, path, headers, client.read(headers['content-length'].to_i)]
  end

  def reply(client, code, json)
    client.write "HTTP/1.1 #{code} OK\r\nContent-Type: application/json\r\n" \
                 "Content-Length: #{json.bytesize}\r\nConnection: close\r\n\r\n#{json}"
  end
end

describe 'Kamal hooks' do
  around do |example|
    Dir.mktmpdir do |dir|
      @passed = dir
      @github = FakeGitHub.new
      example.run
    ensure
      @github.stop
    end
  end

  def hook(name, env)
    base = { 'PERF_PASSED_DIR' => @passed, 'SKIP_PERF' => nil, 'GITHUB_TOKEN' => nil,
             'GITHUB_API_URL' => @github.url, 'GITHUB_REPOSITORY' => 'kleer-la/website17' }
    _out, err, status = Open3.capture3(base.merge(env), ".kamal/hooks/#{name}")
    [status.success?, err]
  end

  def record(version)
    File.write(File.join(@passed, version), '')
  end

  def github_says(state)
    @github.statuses = [{ 'context' => 'perf/qa', 'state' => state }]
  end

  describe 'pre-deploy' do
    it 'stops a production deploy of a commit that did not pass in QA' do
      ok, err = hook('pre-deploy', 'KAMAL_DESTINATION' => '', 'KAMAL_VERSION' => 'abc123')

      expect(ok).to be false
      expect(err).to include 'abc123', 'deploy -d qa'
    end

    it 'lets a production deploy of a commit that passed in QA through' do
      record('abc123')

      expect(hook('pre-deploy', 'KAMAL_DESTINATION' => '', 'KAMAL_VERSION' => 'abc123').first).to be true
    end

    it 'lets a QA deploy through' do
      expect(hook('pre-deploy', 'KAMAL_DESTINATION' => 'qa', 'KAMAL_VERSION' => 'abc123').first).to be true
    end

    it 'can be skipped on purpose, saying so' do
      ok, err = hook('pre-deploy', 'KAMAL_DESTINATION' => '', 'KAMAL_VERSION' => 'abc123', 'SKIP_PERF' => '1')

      expect(ok).to be true
      expect(err).to include 'SKIP_PERF'
    end

    context 'when the commit passed in QA from another machine' do
      it 'lets the deploy through on the perf/qa status GitHub has for it' do
        github_says('success')

        ok, = hook('pre-deploy', 'KAMAL_DESTINATION' => '', 'KAMAL_VERSION' => 'abc123', 'GITHUB_TOKEN' => 't0k')

        expect(ok).to be true
      end

      it 'stops it when the latest perf/qa status is a failure' do
        @github.statuses = [{ 'context' => 'perf/qa', 'state' => 'failure' },
                            { 'context' => 'perf/qa', 'state' => 'success' }]

        ok, = hook('pre-deploy', 'KAMAL_DESTINATION' => '', 'KAMAL_VERSION' => 'abc123', 'GITHUB_TOKEN' => 't0k')

        expect(ok).to be false
      end

      it 'ignores the statuses of other checks' do
        @github.statuses = [{ 'context' => 'ci', 'state' => 'success' }]

        ok, = hook('pre-deploy', 'KAMAL_DESTINATION' => '', 'KAMAL_VERSION' => 'abc123', 'GITHUB_TOKEN' => 't0k')

        expect(ok).to be false
      end

      it 'says a GITHUB_TOKEN would let it ask GitHub, when there is none' do
        github_says('success')

        ok, err = hook('pre-deploy', 'KAMAL_DESTINATION' => '', 'KAMAL_VERSION' => 'abc123')

        expect(ok).to be false
        expect(err).to include 'GITHUB_TOKEN'
      end
    end
  end

  describe 'post-deploy' do
    it 'runs the performance specs on QA and records the commit when they pass' do
      ok, = hook('post-deploy', 'KAMAL_DESTINATION' => 'qa', 'KAMAL_VERSION' => 'abc123', 'PERF_COMMAND' => 'true')

      expect(ok).to be true
      expect(File).to exist(File.join(@passed, 'abc123'))
    end

    it 'fails and records nothing when they fail' do
      ok, = hook('post-deploy', 'KAMAL_DESTINATION' => 'qa', 'KAMAL_VERSION' => 'abc123', 'PERF_COMMAND' => 'false')

      expect(ok).to be false
      expect(Dir.children(@passed)).to be_empty
    end

    it 'does nothing after a production deploy' do
      ok, = hook('post-deploy', 'KAMAL_DESTINATION' => '', 'KAMAL_VERSION' => 'abc123', 'PERF_COMMAND' => 'false')

      expect(ok).to be true
    end

    it 'tells GitHub the commit passed, so a deploy from any machine can see it' do
      hook('post-deploy', 'KAMAL_DESTINATION' => 'qa', 'KAMAL_VERSION' => 'abc123', 'PERF_COMMAND' => 'true',
                          'GITHUB_TOKEN' => 't0k')

      post = @github.posts.last
      expect(post[:path]).to eq '/repos/kleer-la/website17/statuses/abc123'
      expect(post[:auth]).to eq 'Bearer t0k'
      expect(post[:body]).to include('context' => 'perf/qa', 'state' => 'success')
    end

    it 'tells GitHub when the commit failed' do
      hook('post-deploy', 'KAMAL_DESTINATION' => 'qa', 'KAMAL_VERSION' => 'abc123', 'PERF_COMMAND' => 'false',
                          'GITHUB_TOKEN' => 't0k')

      expect(@github.posts.last[:body]).to include('context' => 'perf/qa', 'state' => 'failure')
    end

    it 'still records the commit locally when GitHub cannot be reached, warning about it' do
      ok, err = hook('post-deploy', 'KAMAL_DESTINATION' => 'qa', 'KAMAL_VERSION' => 'abc123', 'PERF_COMMAND' => 'true',
                                    'GITHUB_TOKEN' => 't0k', 'GITHUB_API_URL' => 'http://127.0.0.1:1')

      expect(ok).to be true
      expect(File).to exist(File.join(@passed, 'abc123'))
      expect(err).to include 'GitHub'
    end
  end
end
