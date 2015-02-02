# encoding: utf-8

require 'spec_helper'

describe 'mesos::slave' do
  it_behaves_like 'an installation from mesosphere', {:with_zookeeper => true}

  it_behaves_like 'a configuration of a slave node'

  context 'configuration files in /etc' do
    describe 'zk configuration file' do
      let :zk_file do
        file('/etc/mesos/zk')
      end

      it 'creates it' do
        expect(zk_file).to be_a_file
      end

      it 'contains configured master' do
        expect(zk_file.content).to match /^zk:\/\/localhost:2181\/mesos$/
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
        expect(slave_file.content).to match /^ISOLATION=cgroups\/cpu,cgroups\/mem$/
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
end
