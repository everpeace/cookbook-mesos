# encoding: utf-8

require 'spec_helper'

describe 'mesos::master' do
  it_behaves_like 'an installation from mesosphere'

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

  context 'configuration files in /etc' do
    describe 'zk configuration file' do
      let :zk_file do
        file('/etc/mesos/zk')
      end

      it 'creates it' do
        expect(zk_file).to be_a_file
      end

      it 'contains configured zk string' do
        expect(zk_file.content).to match /^test-master$/
      end
    end

    describe 'general mesos configuration file' do
      let :mesos_file do
        file('/etc/default/mesos')
      end

      it 'creates it' do
        expect(mesos_file).to be_a_file
      end

      it 'contains LOGS variable' do
        expect(mesos_file.content).to match /^LOGS=\/var\/log\/mesos$/
      end

      it 'contains ULIMIT variable' do
        expect(mesos_file.content).to match /^ULIMIT="-n 8192"$/
      end
    end

    describe 'master specific configuration file' do
      let :master_file do
        file('/etc/default/mesos-master')
      end

      it 'creates it' do
        expect(master_file).to be_a_file
      end

      it 'contains PORT variable' do
        expect(master_file.content).to match /^PORT=5050$/
      end

      it 'contains ZK variable' do
        expect(master_file.content).to match /^ZK=`cat \/etc\/mesos\/zk`$/
      end
    end

    describe 'mesos-master directory' do
      it 'creates it' do
        expect(file('/etc/mesos-master')).to be_a_directory
      end

      it 'is empty' do
        expect(Dir.glob('/etc/mesos-master/*')).to be_empty
      end
    end
  end

  describe 'starting mesos-master' do
    let :log_file do
      file '/var/log/mesos/mesos-master.INFO'
    end

    before do
      backend.run_command 'service mesos-master restart'
    end

    it 'logs messages about starting' do
      expect(log_file.content).to match /Starting Mesos master/
    end
  end
end
