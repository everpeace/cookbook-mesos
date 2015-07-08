require 'spec_helper'

describe 'mesos::mesosphere' do
  context 'when all attributes are default, on CentOS 6.6' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '6.6')
      runner.converge(described_recipe)
    end

    it 'adds the mesosphere-noarch yum repository' do
      expect(chef_run).to create_yum_repository('mesosphere-noarch').with(
        baseurl: 'http://repos.mesosphere.io/el/6/noarch/'
      )
    end

    it 'installs the default version of the mesos yum package' do
      expect(chef_run).to install_yum_package 'mesos >= 0.20.1'
    end
  end

  context 'when all attributes are default, on CentOS 7.0' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '7.0')
      runner.converge(described_recipe)
    end

    it 'adds the mesosphere-noarch yum repository' do
      expect(chef_run).to create_yum_repository('mesosphere-noarch').with(
        baseurl: 'http://repos.mesosphere.io/el/7/noarch/'
      )
    end
  end

  context 'when node[:mesos][:mesosphere][:with_zookeeper] = true, on any platform' do
    let :chef_run do
      ChefSpec::ServerRunner.new do |node|
        node.set[:mesos][:mesosphere][:with_zookeeper] = true
      end.converge described_recipe
    end

    it 'includes mesos::zookeeper' do
      expect(chef_run).to include_recipe 'mesos::zookeeper'
    end
  end

  context 'when all attributes are default, on Ubuntu 14.04' do
    let(:chef_run) { ChefSpec::ServerRunner.new.converge described_recipe }

    it 'adds the mesosphere apt repository' do
      expect(chef_run).to add_apt_repository('mesosphere').with(
        uri: "http://repos.mesosphere.com/ubuntu",
        components: %w(trusty main),
        keyserver: 'keyserver.ubuntu.com',
        key: 'E56151BF'
      )
    end

    it 'installs the default version of the mesos package' do
      expect(chef_run).to install_package('mesos').with(
        version: '0.20.1-1.0.ubuntu1404'
      )
    end
  end

  context 'when node[:mesos][:version] == 0.22.1, on Ubuntu 14.04' do
    let :chef_run do
      ChefSpec::ServerRunner.new do |node|
        node.set[:mesos][:version] = '0.22.1'
      end.converge described_recipe
    end

    it 'installs the specified version of the mesos package' do
      expect(chef_run).to install_package('mesos').with(
        version: '0.22.1-1.0.ubuntu1404'
      )
    end
  end
end
