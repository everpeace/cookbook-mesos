# encoding: utf-8

require 'spec_helper'

describe 'mesos::slave' do
  it_behaves_like 'an installation from mesosphere', with_zookeeper: true

  it_behaves_like 'a slave node'

  context 'slave upstart script' do
    describe file '/etc/init/mesos-slave.conf' do
      describe '#content' do
        subject { super().content }
        it { is_expected.to include 'exec /usr/bin/mesos-init-wrapper slave' }
      end
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
        expect(zk_file.content).to match %r{^zk://localhost:2181/mesos$}
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
        expect(mesos_file.content).to match %r{^LOGS=/var/log/mesos$}
      end

      it 'contains ULIMIT variable' do
        expect(mesos_file.content).to match(/^ULIMIT="-n 8192"$/)
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
        expect(slave_file.content).to match %r{^MASTER=`cat /etc/mesos/zk`$}
      end

      it 'contains ISOLATION variable' do
        expect(slave_file.content).to match %r{^ISOLATION=cgroups/cpu,cgroups/mem$}
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
          expect(work_dir_file.content).to match %r{^/tmp/mesos$}
        end
      end

      describe 'rack id file' do
        let :rack_id_file do
          file '/etc/mesos-slave/attributes/rackid'
        end

        it 'exists' do
          expect(rack_id_file).to be_a_file
        end

        it 'contains a rack id' do
          expect(rack_id_file.content).to match(/^us-east-1b$/)
        end
      end
    end
  end
end
