#
# Cookbook Name:: mesos
# Spec:: zookeeper
#

require 'spec_helper'

describe 'mesos::zookeeper' do
  context 'When all attributes are default, on CentOS 6.6' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '6.6')
      runner.converge(described_recipe)
    end

    it 'creates the Cloudera Yum repository' do
      expect(chef_run).to create_yum_repository('cdh').with(
        description: "Cloudera's Distribution for Hadoop, Version 4",
        url: 'http://archive.cloudera.com/cdh4/redhat/6/x86_64/cdh/4/',
        gpgkey: 'http://archive.cloudera.com/cdh4/redhat/6/x86_64/cdh/RPM-GPG-KEY-cloudera'
      )
    end

    %w(
      zookeeper
      zookeeper-server
    ).each do |pkg|
      it "installs #{pkg}" do
        expect(chef_run).to install_package pkg
      end
    end

    it "executes the zookeeper service init or returns true" do
      expect(chef_run).to run_execute "service zookeeper-server init || true"
    end

    it "restarts zookeeper" do
      expect(chef_run).to restart_service("zookeeper-server").with(
        provider: Chef::Provider::Service::Init
      )
    end
  end

  context 'When all attributes are default, on Ubuntu 14.04' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new.converge(described_recipe)
    end

    %w(
      zookeeper
      zookeeperd
      zookeeper-bin
    ).each do |pkg|
      it "installs #{pkg}" do
        expect(chef_run).to install_package pkg
      end
    end

    it 'restarts zookeeper' do
      expect(chef_run).to restart_service('zookeeper').with(
        provider: Chef::Provider::Service::Upstart
      )
    end
  end
end
