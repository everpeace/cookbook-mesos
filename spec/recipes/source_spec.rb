#
# Cookbook Name:: mesos
# Spec:: source
#

require 'spec_helper'

describe 'mesos::source' do
  context 'when all attributes are default, on CentOS 6.6' do
    let :chef_run do
      ChefSpec::ServerRunner.new(platform: 'centos', version: '6.6').converge(described_recipe)
    end

    pkgs = %w(
      python-devel
      zlib-devel
      libcurl-devel
      openssl-devel
      cyrus-sasl-devel
      cyrus-sasl-md5
    )

    pkgs.each do |pkg|
      it "installs the #{pkg} package" do
        expect(chef_run).to install_package pkg
      end
    end
  end

  context 'when all attributes are default, on Ubuntu 14.04' do
    let(:chef_run) { ChefSpec::ServerRunner.new.converge described_recipe }

    %w(
      python
      build-essential
      maven
    ).each do |r|
      it "includes #{r} recipe" do
        expect(chef_run).to include_recipe r
      end
    end

    pkgs = %w(
      unzip
      libtool
      libltdl-dev
      automake
      libcurl3
      libcurl3-gnutls
      libcurl4-openssl-dev
      libsasl2-dev
      python-boto
    )

    pkgs.each do |pkg|
      it "installs the #{pkg} package" do
        expect(chef_run).to install_package pkg
      end
    end

    it 'downloads Mesos zip' do
      expect(chef_run).to create_remote_file "#{Chef::Config[:file_cache_path]}/mesos-0.20.1.zip"
    end

    it 'extracts Mesos to home location' do
      expect(chef_run).to run_execute('extract mesos to /opt').with(
        cwd: '/opt',
        command: "unzip -o #{Chef::Config[:file_cache_path]}/mesos-0.20.1.zip -d ./" \
                 ' && mv mesos-0.20.1 mesos'
      )
    end

    it 'builds mesos from source' do
      expect(chef_run).to run_execute('build mesos from source').with(
        cwd: '/opt/mesos',
        command: './bootstrap && mkdir -p build && cd build && ' \
                 '../configure --prefix=/usr/local && make'
      )
    end

    it 'runs Mesos tests' do
      expect(chef_run).to_not run_execute('test mesos')
    end

    it 'installs mesos to prefix location' do
      expect(chef_run).to run_execute('install mesos to /usr/local').with(
        cwd: '/opt/mesos/build',
        command: 'make install && ldconfig'
      )
    end
  end

  context 'when node[:mesos][:build][:skip_test] == false, on Ubuntu 14.04' do
    let :chef_run do
      ChefSpec::ServerRunner.new do |node|
        node.set[:mesos][:build][:skip_test] = false
      end.converge described_recipe
    end

    it 'runs Mesos tests' do
      expect(chef_run).to run_execute('test mesos').with(
        cwd: '/opt/mesos/build',
        command: 'make check'
      )
    end
  end
end
