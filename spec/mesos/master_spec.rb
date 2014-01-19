# encoding: utf-8

require 'spec_helper'

describe 'mesos::master' do
  before do
    File.stub(:exist?).and_call_original
    File.stub(:exist?).with('/usr/local/sbin/mesos-master').and_return(false)
    File.stub(:exists?).and_call_original
    File.stub(:exists?).with('/usr/local/sbin/mesos-master').and_return(false)

    stub_command('test -L /usr/lib/libjvm.so')
    stub_command("update-alternatives --display java | grep '/usr/lib/jvm/java-6-openjdk-amd64/jre/bin/java - priority 1061'")
    stub_command("/usr/bin/python -c 'import setuptools'")
  end

  shared_examples_for 'a master recipe' do
    it 'creates masters file in deploy directory' do
      expect(chef_run).to create_template '/usr/local/var/mesos/deploy/masters'
    end

    it 'creates slaves file in deploy directory' do
      expect(chef_run).to create_template '/usr/local/var/mesos/deploy/slaves'
    end

    it 'creates deploy env template' do
      expect(chef_run).to create_template '/usr/local/var/mesos/deploy/mesos-deploy-env.sh'
    end

    it 'creates mesos master env template' do
      expect(chef_run).to create_template '/usr/local/var/mesos/deploy/mesos-master-env.sh'
    end
  end

  context 'when installed from mesosphere' do
    let :chef_run do
      ChefSpec::Runner.new do |node|
        node.set[:mesos][:type] = 'mesosphere'
        node.set[:mesos][:mesosphere][:with_zookeeper] = true
      end.converge(described_recipe)
    end

    it_behaves_like 'an installation from mesosphere'
    it_behaves_like 'a master recipe'

    it 'creates /etc/default/mesos-master' do
      expect(chef_run).to create_template '/etc/default/mesos-master'
    end

    it 'creates /etc/mesos-master' do
      expect(chef_run).to create_directory '/etc/mesos-master'
    end

    it 'runs a cleanup of /etc/mesos-master/*' do
      expect(chef_run).to run_bash('cleanup /etc/mesos-master/')
    end

    describe 'configuration options in /etc/mesos-master' do
      pending
    end

    it 'restart mesos-master service' do
      expect(chef_run).to restart_service('mesos-master')
    end
  end

  context 'when installed from source' do
    let :chef_run do
      ChefSpec::Runner.new do |node|
        node.set[:mesos][:type] = 'source'
        node.set[:mesos][:mesosphere][:with_zookeeper] = true
      end.converge(described_recipe)
    end

    it_behaves_like 'an installation from source'
    it_behaves_like 'a master recipe'
  end
end
