# encoding: utf-8

require 'spec_helper'

describe 'mesos::master' do
  it_behaves_like 'an installation from mesosphere', {:with_zookeeper => true}

  it_behaves_like 'a configuration of a master node'

  context 'configuration files in /etc' do
    describe 'zk configuration file' do
      let :zk_file do
        file('/etc/mesos/zk')
      end

      it 'creates it' do
        expect(zk_file).to be_a_file
      end

      it 'contains configured zk string' do
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
    end
  end
end
