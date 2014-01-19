# encoding: utf-8

require 'spec_helper'

describe 'mesos::master' do
  before do
    File.stub(:exist?).and_call_original
    File.stub(:exist?).with('/usr/local/sbin/mesos-master').and_return(false)
    File.stub(:exists?).and_call_original
    File.stub(:exists?).with('/usr/local/sbin/mesos-master').and_return(false)

    stub_command("test -L /usr/lib/libjvm.so")
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

    it_behaves_like 'a master recipe'

    it 'installs default-jre-headless' do
      expect(chef_run).to install_apt_package 'default-jre-headless'
    end

    it 'installs libcurl3' do
      expect(chef_run).to install_package 'libcurl3'
    end

    describe 'workaround symlink for libjvm.so' do
      context 'when /usr/lib/libjvm.so is already a symlink' do
        before do
          stub_command("test -L /usr/lib/libjvm.so").and_return(true)
        end

        it 'does nothing' do
          expect(chef_run).not_to create_link '/usr/lib/libjvm.so'
        end
      end

      context 'when /usr/lib/libjvm.so is not a symlink' do
        it 'creates a symlink' do
          expect(chef_run).to create_link('/usr/lib/libjvm.so').with(to: '/usr/lib/jvm/default-java/jre/lib/amd64/server/libjvm.so')
        end
      end
    end

    describe' with_zookeeper option' do
      it 'installs zookeeper package' do
        expect(chef_run).to install_package 'zookeeper'
      end

      it 'installs zookeeperd package' do
        expect(chef_run).to install_package 'zookeeperd'
      end

      it 'installs zookeeper-bin package' do
        expect(chef_run).to install_package 'zookeeper-bin'
      end

      it 'restart zookeeper service' do
        expect(chef_run).to restart_service 'zookeeper'
      end
    end

    let :mesos_deb do
      chef_run.remote_file(File.join(Chef::Config[:file_cache_path], 'mesos_0.15.0.deb'))
    end

    it 'downloads mesos deb' do
      expect(chef_run).to create_remote_file File.join(Chef::Config[:file_cache_path], 'mesos_0.15.0.deb')
    end

    it 'notifies installation of mesos package using dpkg' do
      expect(mesos_deb).to notify('dpkg_package[mesos]').to(:install).delayed
    end

    it 'creates /etc/mesos/zk' do
      expect(chef_run).to create_template '/etc/mesos/zk'
    end

    it 'creates /etc/default/mesos' do
      expect(chef_run).to create_template '/etc/default/mesos'
    end

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

    before do
      # From java::default recipe
      stub_command("update-alternatives --display java | grep '/usr/lib/jvm/java-6-openjdk-amd64/jre/bin/java - priority 1061'")
      # From python::default recipe
      stub_command("/usr/bin/python -c 'import setuptools'")
    end

    it_behaves_like 'a master recipe'

    it 'includes build-essential recipe' do
      expect(chef_run).to include_recipe 'build-essential'
    end

    it 'includes java recipe' do
      expect(chef_run).to include_recipe 'java'
    end

    it 'includes python recipe' do
      expect(chef_run).to include_recipe 'python'
    end

    it 'includes build_from_source recipe' do
      expect(chef_run).to include_recipe 'mesos::build_from_source'
    end

    describe 'package dependencies' do
      %w[unzip libtool libltdl-dev autoconf automake libcurl3 libcurl3-gnutls libcurl4-openssl-dev python-dev libsasl2-dev].each do |pkg_name|
        it "installs #{pkg_name}" do
          expect(chef_run).to install_package pkg_name
        end
      end
    end

    it 'downloads mesos zip' do
      expect(chef_run).to create_remote_file(File.join(Chef::Config[:file_cache_path], 'mesos-0.15.0.zip'))
    end

    it 'runs bash script for extracting mesos to home location' do
      expect(chef_run).to run_bash('extracting mesos to /opt').with_cwd('/opt')
    end

    it 'builds mesos from source' do
      expect(chef_run).to run_bash('building mesos from source').with_cwd('/opt/mesos')
      expect(chef_run).to run_bash('building mesos from source').with_code(/\.\/bootstrap/)
      expect(chef_run).to run_bash('building mesos from source').with_code(/configure --prefix=\/usr\/local/)
      expect(chef_run).to run_bash('building mesos from source').with_code(/make/)
    end

    it 'installs mesos to prefix location' do
      expect(chef_run).to run_bash('install mesos to /usr/local').with_cwd('/opt/mesos/build')
      expect(chef_run).to run_bash('install mesos to /usr/local').with_code(/make install/)
      expect(chef_run).to run_bash('install mesos to /usr/local').with_code(/ldconfig/)
    end
  end
end
