# encoding: utf-8

require 'spec_helper'

describe 'mesos::slave' do
  it_behaves_like 'an installation from source'

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

  describe 'slave env template' do
    let :slave_env_file do
      file('/usr/local/var/mesos/deploy/mesos-slave-env.sh')
    end

    it 'creates it in deploy directory' do
      expect(slave_env_file).to be_a_file
    end

    it 'contains log_dir variable' do
      expect(slave_env_file.content).to match /^export MESOS_log_dir=\/var\/log\/mesos$/
    end

    it 'contains work_dir variable' do
      expect(slave_env_file.content).to match /^export MESOS_work_dir=\/tmp\/mesos$/
    end

    it 'contains isolation variable' do
      expect(slave_env_file.content).to match /^export MESOS_isolation=cgroups$/
    end
  end
end
