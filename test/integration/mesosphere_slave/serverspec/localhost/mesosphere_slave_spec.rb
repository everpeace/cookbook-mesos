# encoding: utf-8

require 'spec_helper'

describe 'mesos::slave' do
  it_behaves_like 'an installation from mesosphere'

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

  context 'configuration files in /etc' do
    describe 'zk configuration file' do
      let :zk_file do
        file('/etc/mesos/zk')
      end

      it 'creates it' do
        expect(zk_file).to be_a_file
      end

      it 'contains configured master' do
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

    describe 'slave specific configuration file' do
      let :slave_file do
        file('/etc/default/mesos-slave')
      end

      it 'creates it' do
        expect(slave_file).to be_a_file
      end

      it 'contains MASTER variable' do
        expect(slave_file.content).to match /^MASTER=`cat \/etc\/mesos\/zk`$/
      end

      it 'contains ISOLATION variable' do
        expect(slave_file.content).to match /^ISOLATION=cgroups$/
      end
    end

    describe 'mesos-slave directory' do
      it 'creates it' do
        expect(file('/etc/mesos-slave')).to be_a_directory
      end

      describe 'work dir file' do
        let :work_dir_file do
          file '/etc/mesos-slave/work_dir'
        end

        it 'creates it' do
          expect(work_dir_file).to be_a_file
        end

        it 'contains the configured working directory' do
          expect(work_dir_file.content).to match /^\/tmp\/mesos$/
        end
      end
    end
  end

  context 'running mesos-slave' do
    pending 'need to be able to actually start a slave box'
  end
end
