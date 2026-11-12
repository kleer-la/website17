require 'spec_helper'
require 'open3'
require 'tmpdir'

# Kamal runs .kamal/hooks/* on the machine that deploys. A QA deploy runs the
# performance specs and records the commit when they pass (post-deploy); a
# production deploy only goes ahead for a recorded commit (pre-deploy).
describe 'Kamal hooks' do
  around do |example|
    Dir.mktmpdir do |dir|
      @passed = dir
      example.run
    end
  end

  def hook(name, env)
    _out, err, status = Open3.capture3({ 'PERF_PASSED_DIR' => @passed, 'SKIP_PERF' => nil }.merge(env),
                                       ".kamal/hooks/#{name}")
    [status.success?, err]
  end

  def record(version)
    File.write(File.join(@passed, version), '')
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
  end
end
