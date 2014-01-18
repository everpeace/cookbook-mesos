# encoding: utf-8

require 'spec_helper'

describe 'mesos::master' do
  it_behaves_like 'an installation from source'

  describe 'masters file' do
    let :masters_file do
      file '/usr/local/var/mesos/deploy/masters'
    end

    it 'creates it' do
      expect(masters_file).to be_a_file
    end

    it 'contains a newline separated list of configured master IPs' do
      expect(masters_file.content).to match /^#{Regexp.escape('10.0.0.1')}$/
      expect(masters_file.content).to match /^#{Regexp.escape('10.0.0.2')}$/
      expect(masters_file.content).to match /^#{Regexp.escape('10.0.0.3')}$/
    end
  end

  describe 'slaves file' do
    let :slaves_file do
      file '/usr/local/var/mesos/deploy/slaves'
    end

    it 'creates it' do
      expect(slaves_file).to be_a_file
    end

    it 'contains a newline separated list of configured master IPs' do
      expect(slaves_file.content).to match /^#{Regexp.escape('11.0.0.1')}$/
      expect(slaves_file.content).to match /^#{Regexp.escape('11.0.0.2')}$/
      expect(slaves_file.content).to match /^#{Regexp.escape('11.0.0.3')}$/
    end
  end

  describe 'deploy env template' do
    let :deploy_env_file do
      file('/usr/local/var/mesos/deploy/mesos-deploy-env.sh')
    end

    it 'creates it in deploy directory' do
      expect(deploy_env_file).to be_a_file
    end

    it 'contains SSH_OPTS variable' do
      expect(deploy_env_file.content).to match /^export SSH_OPTS="#{Regexp.escape('-o StrictHostKeyChecking=no -o ConnectTimeout=2')}"$/
    end

    it 'contains DEPLOY_WITH_SUDO variable' do
      expect(deploy_env_file.content).to match /^export DEPLOY_WITH_SUDO="1"$/
    end
  end

  describe 'master env template' do
    let :master_env_file do
      file('/usr/local/var/mesos/deploy/mesos-master-env.sh')
    end

    it 'creates it in deploy directory' do
      expect(master_env_file).to be_a_file
    end

    it 'contains log_dir variable' do
      expect(master_env_file.content).to match /^export MESOS_log_dir=\/var\/log\/mesos$/
    end

    it 'contains port variable' do
      expect(master_env_file.content).to match /^export MESOS_port=5050$/
    end
  end

  context 'running mesos-master' do
    let :log_file do
      file '/var/log/mesos/mesos-master.INFO'
    end

    before do
      backend.run_command 'mesos-master --log_dir=/var/log/mesos > /dev/null 2>&1 & sleep 1 && killall mesos-master'
    end

    it 'logs messages about starting' do
      expect(log_file.content).to match /Starting Mesos master/
      expect(log_file.content).to match /Master started on 127.0.1.1:5050/
    end

    it 'logs message about electing itself as master' do
      expect(log_file.content).to match /Elected as master/
    end
  end
end
